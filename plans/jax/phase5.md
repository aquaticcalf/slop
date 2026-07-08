# phase 5: training

**goal:** optimizers, loss functions, and a training loop that compiles the entire train step as one stablehlo program, with data parallelism across the 8-chip tpu v5e pod.

**depends on:** phase 3 + 4

**target hardware:** tpu v5e-8 pod — 2×4 mesh, 8 chips, 1 host, 128 gb total hbm (16 gb/chip), 197 tflops bf16/chip.

## data parallelism strategy

the 350m-class model (~700 mb in bf16) fits comfortably in a single chip's 16 gb hbm. each of the 8 chips holds a full copy of the model and processes a different microbatch:

```
host:     split batch into 8 microbatches
           │
           ▼
chip 0 ── forward/loss/backward ── gradients ──┐
chip 1 ── forward/loss/backward ── gradients ──┤
...                                             ├── all-reduce gradients
chip 7 ── forward/loss/backward ── gradients ──┘
           │
           ▼
     all chips apply the same update (adamw)
```

- no model sharding needed (model fits in 16 gb)
- all-reduce via `pjrt.Executable` + `stablehlo.all_reduce` inserted into the compiled train step
- global batch size = microbatch × 8
- gradient accumulation: repeat forward+backward n times before all-reduce + update

## files

| file | purpose |
|------|---------|
| `pkg/jax/train/main.zig` | module root |
| `pkg/jax/train/optim.zig` | adamw optimizer (state on device) |
| `pkg/jax/train/loss.zig` | cross-entropy, mse |
| `pkg/jax/train/loop.zig` | train step compilation + execution loop, all-reduce |
| `pkg/jax/train/checkpoint.zig` | save/load params + optimizer state (bf16 safetensors) |
| `pkg/jax/train/test/main.zig` | tests |

## optim.zig — adamw optimizer

```zig
pub const AdamW = struct {
    lr: f32,
    beta1: f32,
    beta2: f32,
    eps: f32,
    weight_decay: f32,
    step_t: i64,

    // optimizer state lives on device as graph parameters
    m: []Tensor,           // first moment
    v: []Tensor,           // second moment

    pub fn init(graph: *tensor.Graph, params: []const Tensor, lr: f32, config: AdamWConfig) !AdamW
    pub fn buildStep(self: *AdamW, graph: *tensor.Graph, params: []const Tensor, grads: []const Tensor) Tensor
};
```

`buildStep()` constructs a graph node representing the full parameter update:

```
for each param p with gradient g:
    m = beta1 * m + (1 - beta1) * g
    v = beta2 * v + (1 - beta2) * g^2
    m_hat = m / (1 - beta1^step_t)
    v_hat = v / (1 - beta2^step_t)
    p -= lr * m_hat / (sqrt(v_hat) + eps) + weight_decay * p
```

the entire update compiles as a single stablehlo program — no host-device round-trips per param.

## loss.zig — loss functions

```zig
pub fn crossEntropyLoss(logits: Tensor, targets: Tensor) Tensor
pub fn mseLoss(pred: Tensor, target: Tensor) Tensor
```

- `crossEntropyLoss`: `log_softmax(logits, axis=-1)` → `nll_loss` → scalar
- supports optional label smoothing

## loop.zig — training loop

```zig
pub const Trainer = struct {
    model_fn: *const fn (params: []const Tensor, batch: anytype) Tensor,
    params: *Module,
    optim: *AdamW,
    client: *runtime.Client,
    cache: *graph.Cache,
    grad_accum_steps: usize,
    n_devices: usize,         // 8 for tpu v5e-8 pod

    pub fn trainStep(self: *Trainer, batch: anytype) !f32
    pub fn train(self: *Trainer, data_loader: *DataLoader, n_steps: usize) !void
};
```

`trainStep()`:
1. split batch into `n_devices` microbatches
2. for each device: build forward → loss → backward graph
3. insert `stablehlo.all_reduce` on gradients (sum across devices)
4. build optimizer update graph
5. compile the full graph (or hit cache)
6. execute across all devices
7. return loss value

entire train step is one stablehlo program executed in parallel on 8 chips — critical for tpu utilization.

gradient accumulation: repeat forward+backward n times before all-reduce + update.

## checkpoint.zig

uses the **safetensors** format — the standard in the huggingface/jax ecosystem. simple structure: json header with tensor names/shapes/dtypes + raw data buffers. zero-copy reads, no code execution risk, cross-framework compatible.

```zig
pub fn save(path: []const u8, module: *Module, optim: *AdamW, step: i64) !void
pub fn load(allocator: std.mem.Allocator, path: []const u8, module: *Module, optim: *AdamW) !i64
```

format per safetensors spec:
- 8 bytes: header length (u64 little-endian)
- n bytes: json header (`{"metadata": {...}, "tensors": {"name": {"dtype": "BF16", "shape": [2,3], "data_offsets": [0, 24]}, ...}}`)
- m bytes: raw tensor data (aligned, zero-copy mmap-compatible)

optimizer state (`m`, `v`, `step_t`) stored as additional tensors in the same file with namespaced keys (`"optim.m.0"`, `"optim.v.0"`, `"optim.step"`).

all weights stored in bf16. these checkpoints are the input to phase 7 (quantization).

## tests

- `adam_w.update` — single parameter update, verify against reference math
- `cross_entropy.grad` — verify gradient matches numerical gradient
- `train.mlp` — train 2-layer mlp on toy regression, loss decreases
- `checkpoint.roundtrip` — save, load, weights identical
- `data_parallel.all_reduce` — verify gradient all-reduce produces correct sum
