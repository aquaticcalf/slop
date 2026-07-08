# jax ml library

build a jax-equivalent ml framework in zig. training on google tpu v5e-8 pod (8 chips), inference on android via pure zig `.so`.

## invariants

- `cmd/slop/` and `pkg/slop/` are frozen — never modified.
- new clis live at `cmd/jax/`. new libraries live in `pkg/jax/`.
- every new module gets a corresponding entry in `build.zig` + a test step.
- the `pkg/jax/pjrt/` raw c bindings are never consumed directly by user code — always through `pkg/jax/runtime/`.
- all training phases developed against the cpu pjrt plugin. tpu is a deployment target, not a dev dependency.

## cross-cutting concerns

### error handling

every pjrt call returns `?*error`. the runtime layer converts these to zig errors uniformly:

```zig
fn check(api: *const pjrt.Api, maybe_err: ?*pjrt.Error) !void {
    const err = maybe_err orelse return;
    defer _ = api.error_destroy(&.{ .error = err });
    var msg: [*:0]const u8 = undefined;
    var msg_len: usize = undefined;
    _ = api.error_message(&.{ .error = err, .message = &msg, .message_size = &msg_len });
    return error.PjrtError(msg[0..msg_len]);
}
```

### allocator strategy

| layer | allocator | rationale |
|-------|-----------|-----------|
| graph building | arena (`std.heap.ArenaAllocator`) | nodes never freed individually |
| mlir/hlo text | general purpose | temporary, freed after serialization |
| tensor data | page-aligned | required for dma to/from devices |
| compilation cache | general purpose | long-lived, entries freed individually |
| model params | page-aligned | large buffers, may be persisted |

### testing strategy

- all tests runnable without hardware — use cpu pjrt plugin for ci
- golden value tests: known inputs → known outputs for every op
- gradient checks: numerical gradient vs analytic gradient for every vjp rule
- round-trip tests: host → device → host, assert exact match
- shape error tests: wrong shapes → expected zig error, not panic

### logging + observability

- `std.log` scoped per module (`std.log.scoped(.jax_runtime)`, etc.)
- graph visualization: `graph.toDot()` → graphviz `.dot` file
- hlo dump: `builder.dump()` → print mlir text before serialization
- compilation cache: log cache hits/misses with timing

## phases

| # | phase | depends on | file |
|---|-------|------------|------|
| 1 | pjrt runtime | existing pjrt bindings | `phase1.md` |
| 2 | stablehlo builder | phase 1 | `phase2.md` |
| 3 | graph + autodiff | phase 1 + 2 | `phase3.md` |
| 4 | nn layers | phase 3 | `phase4.md` |
| 5 | training (data parallel on 8 chips) | phase 3 + 4 | `phase5.md` |
| 6 | liquid model + cli | all above | `phase6.md` |
| 7 | quantization (bf16 → int8) | phase 6 | `phase7.md` |
| 8 | android inference engine | phase 7 | `phase8.md` |

## directory layout

```
pkg/jax/
├── main.zig                 # re-exports public api
├── runtime/                 # phase 1
│   ├── main.zig
│   ├── plugin.zig
│   ├── client.zig
│   ├── buffer.zig
│   ├── executable.zig
│   └── test/
├── hlo/                     # phase 2
│   ├── main.zig
│   ├── builder.zig
│   ├── ops.zig
│   ├── types.zig
│   ├── c_api.zig
│   └── test/
├── graph/                   # phase 3
│   ├── main.zig
│   ├── graph.zig
│   ├── tensor.zig
│   ├── node.zig
│   ├── shape.zig
│   ├── grad.zig
│   ├── vjp.zig
│   ├── cache.zig
│   └── test/
├── nn/                      # phase 4
│   ├── main.zig
│   ├── layers.zig
│   ├── attention.zig
│   ├── activations.zig
│   ├── module.zig
│   ├── init.zig
│   └── test/
├── train/                   # phase 5
│   ├── main.zig
│   ├── optim.zig
│   ├── loss.zig
│   ├── loop.zig
│   ├── checkpoint.zig
│   └── test/
├── quant/                   # phase 7
│   ├── main.zig
│   ├── calibrate.zig
│   ├── quantize.zig
│   └── test/
├── infer/                   # phase 8
│   ├── main.zig
│   ├── engine.zig
│   ├── ops.zig
│   ├── jni.zig
│   └── test/
└── liquid/                  # phase 6
    ├── main.zig
    ├── model.zig
    ├── config.zig
    ├── block.zig
    ├── moe.zig
    ├── data/
    │   ├── tokenizer.zig
    │   └── loader.zig
    └── test/

cmd/jax/
├── main.zig                 # cli entry point
├── test/
```

## build targets

| target | command | purpose |
|--------|---------|---------|
| host (x86) | `zig build` | training + dev, cpu pjrt plugin |
| tpu | `zig build -Dtarget=x86_64-linux` | training on tpu vm, link pjrt tpu plugin |
| android | `zig build -Dtarget=aarch64-linux-android` | inference `.so` for android apps |

android requires ndk. the inference library is compiled as a position-independent `.o` then linked against bionic via ndk's `ld.lld`, producing `libjax_infer.so` for `System.loadLibrary()`.

## hardware targets

| stage | hardware | details |
|-------|----------|---------|
| training | tpu v5e-8 pod | 2×4 mesh, 8 chips, 1 host, 128 gb hbm total |
| inference | android device | aarch64, bionic libc, react native / kotlin |
