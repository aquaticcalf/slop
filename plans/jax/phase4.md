# phase 4: neural network layers

**goal:** composable nn layers with parameter management, all operating on `graph.tensor`.

**depends on:** phase 3

## files

| file | purpose |
|------|---------|
| `pkg/jax/nn/main.zig` | module root |
| `pkg/jax/nn/layers.zig` | linear, embedding, layernorm, rmsnorm, dropout |
| `pkg/jax/nn/attention.zig` | multi-head attention, rope, causal mask, kv cache |
| `pkg/jax/nn/activations.zig` | relu, gelu, silu, sigmoid |
| `pkg/jax/nn/module.zig` | parameter container + serialization |
| `pkg/jax/nn/init.zig` | xavier, kaiming, normal, uniform initializers |
| `pkg/jax/nn/test/main.zig` | tests |

all layers are pure graph construction — they take `graph.tensor` handles and return `graph.tensor` handles. no execution happens during layer composition.

## module.zig — parameter container

```zig
pub const Module = struct {
    allocator: std.mem.Allocator,
    params: std.StringArrayHashMap(Param),

    pub const Param = struct {
        shape: Shape,
        dtype: DType,
        init_fn: InitFn,
        trainable: bool,
    };

    pub fn init(allocator: std.mem.Allocator) Module
    pub fn add(self: *Module, name: []const u8, shape: Shape, init_fn: InitFn) !void
    pub fn toGraph(self: *Module, graph: *tensor.Graph) !std.StringArrayHashMap(Tensor)
    pub fn save(self: *Module, writer: std.io.AnyWriter) !void
    pub fn load(allocator: std.mem.Allocator, reader: std.io.AnyReader) !Module
};
```

serialization format: `(name_len, name, dtype, ndim, dims..., data_bytes)` for each param.

## layers.zig — standard layers

```zig
pub fn linear(x: Tensor, weight: Tensor, bias: ?Tensor) Tensor
pub fn embedding(ids: Tensor, table: Tensor) Tensor
pub fn layerNorm(x: Tensor, gamma: Tensor, beta: Tensor, eps: f32) Tensor
pub fn rmsNorm(x: Tensor, gamma: Tensor, eps: f32) Tensor
pub fn dropout(x: Tensor, rate: f32, rng_state: *Tensor) Tensor  // training only
```

## attention.zig — attention mechanisms

```zig
pub fn scaledDotProductAttention(q: Tensor, k: Tensor, v: Tensor, mask: ?Tensor, scale: ?f32) Tensor
pub fn multiHeadAttention(x: Tensor, w_q: Tensor, w_k: Tensor, w_v: Tensor, w_o: Tensor, mask: ?Tensor, n_heads: usize) Tensor
pub fn causalMask(seq_len: i64, graph: *tensor.Graph) Tensor
pub fn rotaryEmbedding(x: Tensor, positions: Tensor, theta: f32) Tensor
pub fn kvCacheUpdate(cache: Tensor, new_k: Tensor, new_v: Tensor, position: Tensor) struct { Tensor, Tensor }
```

## activations.zig

```zig
pub fn relu(x: Tensor) Tensor       // max(x, 0) — compound, expands to compare+select
pub fn gelu(x: Tensor) Tensor       // x * 0.5 * (1 + erf(x / sqrt(2)))
pub fn silu(x: Tensor) Tensor       // x * sigmoid(x)
pub fn sigmoid(x: Tensor) Tensor    // 1 / (1 + exp(-x))
```

## init.zig — parameter initializers

```zig
pub const InitFn = union(enum) {
    xavier_uniform: struct { gain: f32 = 1.0 },
    xavier_normal: struct { gain: f32 = 1.0 },
    kaiming_uniform: struct { a: f32 = std.math.sqrt(5.0) },
    kaiming_normal: struct { a: f32 = 0.0 },
    normal: struct { mean: f32 = 0.0, std: f32 = 1.0 },
    uniform: struct { lo: f32 = -1.0, hi: f32 = 1.0 },
    zeros: void,
    ones: void,
};
```

## tests

- `linear.forward` — create linear, forward pass, verify output shape + values
- `attention.forward` — single mha head, compare against reference
- `attention.grad` — forward + backward through mha, gradient shapes match param shapes
- `layer_norm.forward` — layernorm on known input, verify output
- `module.save_load` — round-trip params through serialization, exact match
- `init.statistics` — verify xavier/kaiming produce correct variance
