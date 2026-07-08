# phase 6: liquid foundation model + cli

**goal:** build a liquid foundation model using a hybrid gated-conv + gqa architecture (lfm2-inspired), with a separate `cmd/jax/` cli for training, eval, and inference.

**depends on:** all previous phases

## architecture overview

hybrid of **double-gated short convolutions** + **grouped query attention**. most layers are gated conv blocks (linear complexity, constant memory per layer), with a minority of gqa blocks for global context.

```
embedding → n_layers × (gated_conv_block | gqa_block) → rmsnorm → linear_head
```

the architecture is **parameterized** — the config struct defines layer counts, dimensions, and whether gqa uses sliding window or full attention. default starting point targets the ~350m parameter class.

## files

| file | purpose |
|------|---------|
| `pkg/jax/liquid/main.zig` | module root |
| `pkg/jax/liquid/config.zig` | model configuration (parameterized) |
| `pkg/jax/liquid/block.zig` | gated conv block + gqa attention block |
| `pkg/jax/liquid/moe.zig` | mixture of experts (top-k routing) |
| `pkg/jax/liquid/model.zig` | full model assembly |
| `pkg/jax/liquid/data/tokenizer.zig` | bpe tokenizer (quicktok c abi) |
| `pkg/jax/liquid/data/loader.zig` | mem-mapped data loading + batching |
| `pkg/jax/liquid/test/main.zig` | tests |
| `cmd/jax/main.zig` | cli — train / eval / generate / quantize |
| `cmd/jax/test/main.zig` | cli tests |

## config.zig — parameterized model configuration

```zig
pub const LFMConfig = struct {
    vocab_size: usize = 65536,
    d_model: usize,
    n_heads: usize,
    n_kv_heads: usize,         // gqa: k/v heads < query heads
    n_conv_blocks: usize,      // number of double-gated conv blocks
    n_attention_blocks: usize, // number of gqa attention blocks
    d_ff: usize,               // swiglu hidden dimension
    conv_kernel_size: usize = 3,
    sliding_window: ?usize = null,  // null = full attention, some(n) = bounded kv cache
    norm_eps: f32 = 1e-5,
    max_seq_len: usize = 32768,
    use_moe: bool = false,
    moe_num_experts: usize = 32,
    moe_top_k: usize = 4,
    dropout_rate: f32 = 0.0,
};
```

`sliding_window` controls gqa behavior:
- `null` = standard full-causal attention (kv cache grows with sequence length for gqa layers)
- `some(4096)` = sliding window at window size 4096 (kv cache capped, constant memory)

layer interleaving pattern: config-driven, not hardcoded. `n_conv_blocks` and `n_attention_blocks` define the counts; the interleaving schedule is a separate parameter or a heuristic (e.g., start with 2 conv blocks for stability, then alternating).

## block.zig — the two block types

### double-gated conv block

```
input: h (seq_len × d_model)
     │
     ├── rmsnorm(h)
     │
     ├── linear projection → split into [B, C, h_tilde]
     │    B: gate (input-dependent)
     │    C: gate (input-dependent)
     │    h_tilde: values
     │
     ├── y = B ⊙ h_tilde          (first gate)
     ├── z = depthwise_conv1d(y)  (short-range, kernel=k)
     ├── o = C ⊙ z                (second gate)
     │
     └── linear_proj(o) + residual(h)
```

```zig
pub fn gatedConvBlock(
    x: Tensor,
    w_proj: Tensor,     // projects d_model → 3 * d_model
    w_out: Tensor,      // projects d_model → d_model
    conv_weight: Tensor, // depthwise conv kernel [k, d_model]
    norm_weight: Tensor,
    norm_bias: Tensor,
    kernel_size: usize,  // default 3
    eps: f32,
) Tensor {
    const h = rmsNorm(x, norm_weight, norm_bias, eps);
    const projected = linear(h, w_proj, null);  // [L, 3d]
    const b = slice(projected, 0, d_model);     // gate 1
    const c = slice(projected, d_model, 2*d_model); // gate 2
    const h_tilde = slice(projected, 2*d_model, 3*d_model); // values
    const y = mul(b, h_tilde);                   // first gate
    const z = depthwiseConv1d(y, conv_weight, kernel_size); // local mixing
    const o = mul(c, z);                         // second gate
    const out = linear(o, w_out, null);          // project back
    return add(x, out);                          // residual
}
```

key properties:
- **linear complexity** o(l * d) in sequence length
- **no positional encoding** — convolution is position-aware by construction
- **input-dependent gating** — the b and c gates depend on the input, making it "liquid"
- **depthwise conv** — separate kernel per channel, computationally cheap
- **conv_kernel_size=3** (confirmed from lfm2 paper)
- **constant memory** — no kv cache, state is just the current token

### gqa attention block

standard grouped-query attention with rmsnorm pre-norm and swiglu mlp:

```zig
pub fn gqaBlock(
    x: Tensor,
    w_q: Tensor, w_k: Tensor, w_v: Tensor, w_o: Tensor,
    w_gate: Tensor, w_up: Tensor, w_down: Tensor,
    norm_attn_weight: Tensor, norm_mlp_weight: Tensor,
    n_heads: usize, n_kv_heads: usize, eps: f32,
    rope_theta: f32, position_ids: Tensor,
    sliding_window: ?usize,  // null = full, some(n) = windowed
) Tensor {
    // attention sub-block
    const h = rmsNorm(x, norm_attn_weight, null, eps);
    const attn_out = groupedQueryAttention(h, w_q, w_k, w_v, w_o,
        n_heads, n_kv_heads, rope_theta, position_ids, sliding_window);
    const h_attn = add(x, attn_out);

    // swiglu mlp sub-block
    const h2 = rmsNorm(h_attn, norm_mlp_weight, null, eps);
    const gate = silu(linear(h2, w_gate, null));
    const up = linear(h2, w_up, null);
    const mlp_out = linear(mul(gate, up), w_down, null);
    return add(h_attn, mlp_out);
}
```

- gqa: `n_kv_heads < n_heads`, k/v heads repeated per query group
- rope applied to q and k (standard rotary embeddings)
- pre-norm with rmsnorm (no bias)
- `sliding_window`: when set, attention only attends to the last `window` tokens, capping the kv cache

## moe.zig — mixture of experts

for scaling beyond dense models, replace the swiglu mlp in gqa blocks (or conv blocks) with a sparse moe:

```zig
pub const MoEConfig = struct {
    num_experts: usize,
    top_k: usize,
    d_model: usize,
    d_ff: usize,
};

pub fn sparseMoE(
    x: Tensor,
    experts: []const MoEExpert,
    router_weight: Tensor,
    config: MoEConfig,
) Tensor {
    const logits = linear(x, router_weight, null);
    const routing_weights = softmax(logits, -1);
    const top_k_weights, const top_k_indices = topK(routing_weights, config.top_k);
    var output: Tensor = zeros_like(x);
    for (config.top_k) |k| {
        const expert_idx = top_k_indices[..., k];
        const expert = experts[expert_idx];
        const gate = silu(linear(x, expert.w_gate, null));
        const up = linear(x, expert.w_up, null);
        const expert_out = linear(mul(gate, up), expert.w_down, null);
        output = add(output, mul(expert_out, top_k_weights[..., k]));
    }
    return output;
}
```

- normalized sigmoid router with adaptive bias for load balancing
- first 2 layers kept dense for training stability

## model.zig — full model assembly

```zig
pub fn liquidModel(
    input_ids: Tensor,
    position_ids: Tensor,
    config: *const LFMConfig,
    params: *const LMFParams,
) Tensor {
    var h = embedding(input_ids, params.token_embedding);

    for (config.n_conv_blocks + config.n_attention_blocks) |i| {
        if (isConvBlock(i, config)) {
            h = gatedConvBlock(h,
                params.conv_blocks[i].w_proj,
                params.conv_blocks[i].w_out,
                params.conv_blocks[i].conv_weight,
                params.conv_blocks[i].norm_weight,
                null,
                config.conv_kernel_size,
                config.norm_eps,
            );
        } else {
            h = gqaBlock(h,
                params.attn_blocks[i].w_q, params.attn_blocks[i].w_k,
                params.attn_blocks[i].w_v, params.attn_blocks[i].w_o,
                params.attn_blocks[i].w_gate, params.attn_blocks[i].w_up,
                params.attn_blocks[i].w_down,
                params.attn_blocks[i].norm_attn,
                params.attn_blocks[i].norm_mlp,
                config.n_heads, config.n_kv_heads,
                config.norm_eps,
                config.rope_theta,
                position_ids,
                config.sliding_window,
            );
        }
    }

    h = rmsNorm(h, params.final_norm_weight, null, config.norm_eps);
    h = linear(h, params.lm_head, null);
    return h;
}
```

- weight tying: `lm_head` shares weights with `token_embedding` (optional, via config)
- all compute in bf16, master weights in f32
- no dropout during inference

## data/tokenizer.zig — tokenizer

ffi to [quicktok](https://github.com/dmatth1/quicktok) via its **c abi** (`quicktok.h`). byte-identical to tiktoken, 4-11x faster. supports cl100k, o200k, llama-3, qwen2.5/3 vocabs.

```zig
pub const Tokenizer = struct {
    handle: *qt_tokenizer,
    pad_token_id: i64,
    bos_token_id: i64,
    eos_token_id: i64,
    vocab_size: usize,

    pub fn init(allocator: std.mem.Allocator, path: []const u8, encoding: []const u8) !Tokenizer
    pub fn deinit(self: *Tokenizer) void
    pub fn encode(self: *Tokenizer, text: []const u8) ![]i64
    pub fn decode(self: *Tokenizer, ids: []const i64) ![]u8
    pub fn encodeBatch(self: *Tokenizer, texts: []const []const u8) ![][]i64
};
```

uses the c abi functions (`qt_load_dir`, `qt_encode`, `qt_decode`, `qt_ids_free`, `qt_str_free`) for stable ffi from zig.

vocab size: 65536 (byte-level bpe).

## data/loader.zig — data loader

```zig
pub const DataLoader = struct {
    tokens: []i64,
    seq_len: usize,
    batch_size: usize,
    position: usize,
    epoch: usize,

    pub fn init(path: []const u8, seq_len: usize, batch_size: usize) !DataLoader
    pub fn deinit(self: *DataLoader) void
    pub fn nextBatch(self: *DataLoader, graph: *tensor.Graph) !Batch
    pub fn shuffle(self: *DataLoader) void
    pub fn reset(self: *DataLoader) void

    pub const Batch = struct {
        input_ids: []i64,
        target_ids: []i64,
        loss_mask: []f32,
    };
};
```

memory-mapped i/o for large corpora. sequence packing: concatenate short sequences up to `seq_len`.

## cmd/jax/main.zig — cli

```
jax train     --config=<path> --data=<path> --checkpoint=<path> --n-steps=<n>
jax eval      --model=<path> --data=<path>
jax generate  --model=<path> --prompt="..." --temperature=0.7 --max-tokens=256
jax quantize  --input=<bf16-checkpoint> --output=<int8-checkpoint> --calibration=<data>
jax compile   --program=<path> --output=<path>
```

separate `build.zig` entry:

```zig
const jax_exe_mod = b.createModule(.{
    .root_source_file = b.path("cmd/jax/main.zig"),
    .target = target,
    .optimize = optimize,
    .imports = &.{
        .{ .name = "jax-runtime", .module = jax_runtime_mod },
        .{ .name = "jax-hlo", .module = jax_hlo_mod },
        .{ .name = "jax-graph", .module = jax_graph_mod },
        .{ .name = "jax-nn", .module = jax_nn_mod },
        .{ .name = "jax-train", .module = jax_train_mod },
    },
});
const jax_exe = b.addExecutable(.{ .name = "jax", .root_module = jax_exe_mod });
b.installArtifact(jax_exe);
```

## tpu-specific considerations

- **target hardware**: tpu v5e-8 pod — 2×4 mesh, 8 chips, 1 host, 16 gb hbm/chip
- **training parallelism**: data parallel across 8 chips (each holds full model copy)
- **bf16 everywhere**: all compute in bfloat16, master weights in f32
- **depthwise conv on tpu**: stablehlo `convolution` op supports depthwise with `feature_group_count = d_model`. use small kernel (3) with causal padding for autoregressive
- **gradient checkpointing**: recompute activations during backward to save memory
- **sequence packing**: pack multiple sequences into one example to maximize tpu utilization
- **compilation caching**: essential — models can take minutes to compile

## tests

- small model: `n_conv_blocks=4, n_attention_blocks=2, d_model=128` on tiny corpus
- verify conv block forward pass against reference
- verify gqa block produces correct attention output (full + sliding window modes)
- loss decreases monotonically during training
- generate text with temperature sampling, top-k, top-p
- checkpoint → restore → loss trajectory matches
- inference-only mode: no gradient computation
