# phase 8: android inference engine

**goal:** a pure zig `.so` library that runs the quantized int8 model on android, callable from kotlin (jni) and react native.

**depends on:** phase 7

**target:** `aarch64-linux-android` (bionic libc via ndk), built as a shared library for `System.loadLibrary()`.

## approach

a standalone inference engine that:
- loads the int8 safetensors checkpoint + json config
- runs forward pass only (no graph building, no autodiff, no stablehlo)
- dequantizes weights per channel on-the-fly during matmul/conv
- exposes a simple c abi for jni binding

no dependency on the training stack (`runtime/`, `hlo/`, `graph/`, `nn/`, `train/`).

## files

| file | purpose |
|------|---------|
| `pkg/jax/infer/main.zig` | module root + c abi exports |
| `pkg/jax/infer/engine.zig` | model load, forward pass orchestration |
| `pkg/jax/infer/ops.zig` | raw tensor ops: matmul, conv1d, rmsnorm, embedding, silu, softmax, rope, attention |
| `pkg/jax/infer/jni.zig` | jni bridge functions |
| `pkg/jax/infer/test/main.zig` | tests |

## engine.zig — inference engine

```zig
pub const InferenceEngine = struct {
    model: QuantizedModel,   // loaded from int8 safetensors
    config: LFMConfig,       // architecture parameters
    kv_cache: KVCache,       // key-value cache for gqa layers

    pub fn init(allocator: std.mem.Allocator, model_path: []const u8, config_path: []const u8) !InferenceEngine
    pub fn deinit(self: *InferenceEngine) void

    pub fn forward(
        self: *InferenceEngine,
        tokens: []const i32,       // input token ids
        position: i64,             // start position (for autoregressive generation)
        sliding_window: ?usize,    // null = full attention, some(n) = windowed
    ) ![]f32                       // logits for next token
};
```

## ops.zig — raw tensor ops

all ops operate on flat slices (`[]f32` or `[]i8` for quantized weights) with explicit shape parameters. no graph abstraction.

```zig
// matmul: a [m, k] × b [k, n] = c [m, n]
// if a is quantized int8: a_q, scales_a[n], zero_points_a[n]
pub fn matmul(c: []f32, a: []f32, b: []const i8, scales: []const f32, zero_points: []const i8, m: usize, k: usize, n: usize) void

// depthwise 1d conv
pub fn depthwiseConv1d(out: []f32, input: []f32, weight: []const i8, scale: f32, zero_point: i8, seq_len: usize, d_model: usize, kernel: usize) void

// rmsnorm
pub fn rmsnorm(out: []f32, x: []f32, weight: []const i8, weight_scale: f32, weight_zp: i8, eps: f32) void

// silu
pub fn silu(out: []f32, x: []f32) void

// softmax
pub fn softmax(out: []f32, x: []f32, axis: usize) void

// rotary embeddings (rope)
pub fn applyRope(q: []f32, k: []f32, positions: []const i32, theta: f32, d_model: usize) void

// grouped query attention (full + sliding window)
pub fn groupedQueryAttention(
    out: []f32,
    q: []f32, k: []f32, v: []f32,
    kv_cache: *KVCache,
    n_heads: usize, n_kv_heads: usize,
    sliding_window: ?usize,
) void
```

## kv cache

for gqa layers:
- `sliding_window = null`: cache grows with sequence length (unbounded for the 6 gqa layers)
- `sliding_window = some(4096)`: ring buffer of fixed size, oldest entries overwritten

```zig
pub const KVCache = struct {
    k: []f32,
    v: []f32,
    max_seq_len: usize,
    current_len: usize,
    sliding_window: ?usize,
};
```

## c abi — the public interface

`pkg/jax/infer/main.zig` exports a c-compatible api that jni can call:

```c
// load model from safetensors + json config
void* infer_init(const char* model_path, const char* config_path);

// free model
void infer_free(void* engine);

// generate next token logits
// tokens: input token ids, returns logits array (f32, vocab_size)
// sets *out_len to vocab_size
float* infer_forward(void* engine, const int32_t* tokens, int32_t n_tokens,
                      int64_t position, int32_t sliding_window, int32_t* out_len);

// free output array
void infer_free_float_array(float* arr);
```

## jni bridge

`jni.zig` wraps the c abi into jni-compatible function signatures for kotlin:

```zig
// called from kotlin via System.loadLibrary("jax_infer")
pub fn Java_com_example_Model_init(env: *JNIEnv, _: jclass, model_path: jstring, config_path: jstring) jlong
pub fn Java_com_example_Model_forward(env: *JNIEnv, _: jclass, engine_ptr: jlong, tokens: jintArray, position: jlong, sliding_window: jint) jfloatArray
pub fn Java_com_example_Model_free(env: *JNIEnv, _: jclass, engine_ptr: jlong) void
```

## build

the inference library is built separately from the training stack with the android target:

```zig
// in build.zig
const infer_mod = b.createModule(.{
    .root_source_file = b.path("pkg/jax/infer/main.zig"),
    .target = b.resolveTargetQuery(.{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .android }),
    .optimize = .ReleaseSmall,
});

const infer_lib = b.addLibrary(.{
    .name = "jax_infer",
    .linkage = .dynamic,   // .so for System.loadLibrary()
    .root_module = infer_mod,
});
// link against ndk bionic:
// 1. compile to .o via zig
// 2. link with ndk's ld.lld against /path/to/ndk/sysroot/usr/lib/aarch64-linux-android/
// 3. run termux-elf-cleaner for proper tls alignment
```

android build steps:
1. install android ndk
2. set environment variables: `ANDROID_NDK_HOME`, `ANDROID_TARGET=aarch64-linux-android21`
3. `zig build -Dtarget=aarch64-linux-android -Doptimize=ReleaseSmall`
4. the build script links the zig object against ndk's bionic, producing `libjax_infer.so`
5. copy `libjax_infer.so` to `android/app/src/main/jniLibs/arm64-v8a/`

## kotlin usage

```kotlin
class LFMEngine {
    private var nativePtr: Long = 0

    external fun init(modelPath: String, configPath: String): Long
    external fun forward(enginePtr: Long, tokens: IntArray, position: Long, slidingWindow: Int): FloatArray
    external fun free(enginePtr: Long)

    companion object {
        init { System.loadLibrary("jax_infer") }
    }
}
```

## react native usage

wrap the kotlin class in a native module and expose it to javascript:

```typescript
import { NativeModules } from 'react-native';
const { LFMInference } = NativeModules;

const logits = await LFMInference.generate(tokens, position, slidingWindow);
```

## tests

- `forward.conv_block` — run gated conv block on known input, verify output matches reference
- `forward.gqa_block` — run gqa block (full + sliding window modes)
- `forward.full_model` — run the full model end-to-end on a short input
- `kv_cache.ring_buffer` — verify sliding window eviction works correctly
- `kv_cache.growth` — verify full attention kv cache grows correctly
- `checkpoint.load` — load int8 safetensors, verify weights match
- `jni.bindings` — verify jni function signatures are valid (compile-time)
