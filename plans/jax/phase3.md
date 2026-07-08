# phase 3: lazy computation graph + autodiff

**goal:** user-facing `tensor` type that records ops into a computation graph, compiles on demand, and supports reverse-mode autodiff.

**depends on:** phase 1 + 2

## design

```
tensor ops (user calls)
        │
        ▼
graph: arena-allocated dag of nodes
        │
        ├──► shape inference (early error)
        │
        ├──► compile() → hlo.builder → stablehlo bytecode → pjrt compile
        │
        └──► grad(output, params) → new subgraph (reverse-mode ad)
                 │
                 └──► compile() → hlo.builder → stablehlo bytecode → pjrt compile
```

everything is lazy. no tensor data is materialized until `.eval()` or `.execute()` is called.

all ops decompose to primitives at graph-build time — `relu`, `softmax`, `gelu` expand immediately, so autodiff gets them for free.

## files

| file | purpose |
|------|---------|
| `pkg/jax/graph/main.zig` | module root |
| `pkg/jax/graph/graph.zig` | arena-allocated dag of nodes |
| `pkg/jax/graph/tensor.zig` | user-facing tensor handle |
| `pkg/jax/graph/node.zig` | tagged union of all ops |
| `pkg/jax/graph/shape.zig` | shape inference per op |
| `pkg/jax/graph/grad.zig` | reverse-mode ad on the graph |
| `pkg/jax/graph/vjp.zig` | vjp rules per op |
| `pkg/jax/graph/cache.zig` | compilation cache (hash → executable) |
| `pkg/jax/graph/test/main.zig` | tests |

## graph.zig — computation graph

```zig
pub const Graph = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    nodes: std.MultiArrayList(Node),
    node_count: usize,

    pub fn init(allocator: std.mem.Allocator) !Graph
    pub fn deinit(self: *Graph) void

    pub fn parameter(self: *Graph, shape: Shape, name: []const u8) !Tensor
    pub fn constant(self: *Graph, comptime T: type, data: []const T, shape: Shape) !Tensor
    pub fn addNode(self: *Graph, tag: NodeTag, inputs: []const Tensor, attrs: NodeAttrs, output_shape: Shape) !Tensor

    pub fn compile(self: *Graph, client: *runtime.Client, cache: ?*Cache) !CompiledProgram
    pub fn grad(self: *Graph, loss: Tensor, params: []const Tensor) !GradResult
    pub fn dump(self: *Graph, writer: std.io.AnyWriter) !void  // dot format
};
```

- `MultiArrayList` for cache-friendly traversal during compilation and ad
- arena allocator: all nodes freed at once when graph is destroyed
- `compile()` walks dag in topological order → `hlo.builder` → bytecode → pjrt compile

## node.zig — node representation

```zig
pub const Node = struct {
    tag: NodeTag,
    inputs: []const u32,       // node indices
    attrs: NodeAttrs,          // op-specific attributes
    output_shape: Shape,
    name: ?[]const u8,
};

pub const NodeTag = enum {
    parameter, constant,
    add, multiply, subtract, divide, negate,
    exp, log, tanh, rsqrt,
    dot_general, transpose, reshape, broadcast_in_dim,
    reduce, reduce_sum, reduce_max, reduce_mean,
    slice, concatenate, pad, gather, scatter,
    select, iota, convert, compare,
};

pub const NodeAttrs = union {
    dot_general: DotConfig,
    transpose: struct { perm: []const i64 },
    reshape: struct { new_shape: Shape },
    broadcast_in_dim: struct { broadcast_dims: []const i64 },
    reduce: struct { axes: []const i64, init_value: f64, kind: ReduceKind },
    slice: struct { starts: []const i64, limits: []const i64, strides: []const i64 },
    concatenate: struct { axis: i64 },
    compare: struct { direction: CompareDirection },
    convert: struct { target_type: DType },
    select: void,
    iota: struct { iota_dim: i64 },
    constant: struct { data: []u8 },
    parameter: struct { name: []const u8 },
};
```

## tensor.zig — user-facing api

```zig
pub const Tensor = struct {
    graph: *Graph,
    node_id: u32,

    pub fn matmul(a: Tensor, b: Tensor) Tensor
    pub fn add(a: Tensor, b: Tensor) Tensor
    pub fn mul(a: Tensor, b: Tensor) Tensor
    pub fn sub(a: Tensor, b: Tensor) Tensor
    pub fn div(a: Tensor, b: Tensor) Tensor
    pub fn neg(x: Tensor) Tensor
    pub fn exp(x: Tensor) Tensor
    pub fn log(x: Tensor) Tensor
    pub fn tanh(x: Tensor) Tensor
    pub fn rsqrt(x: Tensor) Tensor
    pub fn relu(x: Tensor) Tensor
    pub fn gelu(x: Tensor) Tensor
    pub fn silu(x: Tensor) Tensor
    pub fn softmax(x: Tensor, axis: i64) Tensor
    pub fn layerNorm(x: Tensor, gamma: Tensor, beta: Tensor, eps: f32) Tensor
    pub fn rmsNorm(x: Tensor, gamma: Tensor, eps: f32) Tensor
    pub fn transpose(x: Tensor, perm: []const i64) Tensor
    pub fn reshape(x: Tensor, new_shape: Shape) Tensor
    pub fn cast(x: Tensor, dtype: DType) Tensor
    pub fn slice(x: Tensor, starts: []const i64, limits: []const i64, strides: []const i64) Tensor
    pub fn concat(xs: []const Tensor, axis: i64) Tensor
    pub fn gather(x: Tensor, indices: Tensor, config: GatherConfig) Tensor
    pub fn where(cond: Tensor, on_true: Tensor, on_false: Tensor) Tensor
    pub fn reduceSum(x: Tensor, axes: []const i64) Tensor
    pub fn reduceMax(x: Tensor, axes: []const i64) Tensor
    pub fn reduceMean(x: Tensor, axes: []const i64) Tensor
};
```

## shape.zig — shape inference

every op has a shape inference function called at graph-build time:

```zig
pub fn inferMatmulShape(a: Shape, b: Shape) !Shape
pub fn inferAddShape(a: Shape, b: Shape) !Shape    // handles broadcasting
pub fn inferSoftmaxShape(x: Shape, axis: i64) !Shape
// ... one per op
```

broadcasting follows numpy rules (same as jax). shape mismatches return a zig error.

## cache.zig — compilation cache

```zig
pub const Cache = struct {
    allocator: std.mem.Allocator,
    entries: std.AutoHashMapUnmanaged(u64, CacheEntry),

    pub const CacheEntry = struct {
        executable: *runtime.LoadedExecutable,
        input_shapes: []const Shape,
        output_shapes: []const Shape,
    };

    pub fn init(allocator: std.mem.Allocator) Cache
    pub fn deinit(self: *Cache) void
    pub fn getOrCompile(self: *Cache, graph: *Graph, client: *runtime.Client) !CacheEntry
};
```

- hash: fnv1a of `(node_tag, input_node_ids, attrs, output_shape)` for each node
- cache key changes when shapes change — no stale executables
- `Cache.deinit()` destroys all cached executables

## grad.zig — reverse-mode autodiff

```zig
pub fn grad(graph: *Graph, loss: Tensor, params: []const Tensor) !GradResult

pub const GradResult = struct {
    grad_graph: *Graph,        // new graph that computes gradients
    grad_outputs: []Tensor,    // gradient tensors for each param
};
```

algorithm:
1. topological sort the graph from output backward (kahn's algorithm)
2. initialize seed gradient: constant `1.0` with shape of loss
3. for each node in reverse topological order:
   a. lookup vjp rule from `vjp.zig`
   b. apply vjp rule: given accumulated gradient `g` and node's inputs/outputs, produce gradients for each input
   c. accumulate gradients: when a value feeds multiple consumers, sum all incoming gradients
4. return the gradient graph

the gradient graph can be compiled, cached, dumped — same as any other graph.

## vjp.zig — vjp rules

```zig
pub fn vjpAdd(g: Tensor, a: Tensor, b: Tensor, out: Tensor) struct { Tensor, Tensor }
pub fn vjpMultiply(g: Tensor, a: Tensor, b: Tensor, out: Tensor) struct { Tensor, Tensor }
pub fn vjpDotGeneral(g: Tensor, a: Tensor, b: Tensor, out: Tensor, config: DotConfig) struct { Tensor, Tensor }
pub fn vjpExp(g: Tensor, x: Tensor, out: Tensor) Tensor
pub fn vjpLog(g: Tensor, x: Tensor, out: Tensor) Tensor
pub fn vjpTanh(g: Tensor, x: Tensor, out: Tensor) Tensor
pub fn vjpRsqrt(g: Tensor, x: Tensor, out: Tensor) Tensor
pub fn vjpReshape(g: Tensor, x: Tensor, out: Tensor) Tensor
pub fn vjpTranspose(g: Tensor, x: Tensor, out: Tensor, perm: []const i64) Tensor
pub fn vjpBroadcastInDim(g: Tensor, x: Tensor, out: Tensor, broadcast_dims: []const i64) Tensor
pub fn vjpReduceSum(g: Tensor, x: Tensor, out: Tensor, axes: []const i64) Tensor
pub fn vjpConvert(g: Tensor, x: Tensor, out: Tensor) Tensor
pub fn vjpSlice(g: Tensor, x: Tensor, out: Tensor, starts: []const i64, limits: []const i64, strides: []const i64) Tensor
pub fn vjpGather(g: Tensor, x: Tensor, indices: Tensor, out: Tensor, config: GatherConfig) Tensor
pub fn vjpSelect(g: Tensor, cond: Tensor, on_true: Tensor, on_false: Tensor, out: Tensor) struct { Tensor, Tensor }
pub fn vjpConcatenate(g: Tensor, xs: []const Tensor, out: Tensor, axis: i64) []Tensor
```

compound ops (`softmax`, `relu`, `gelu`) decompose to primitives during graph construction — their vjp is automatic.

## tests

- `graph.simple_math`: `x * y + x` compile + execute, verify output
- `graph.matmul`: `a @ b` with known values, verify output
- `graph.shape_error`: mismatched shapes → error, not panic
- `grad.x_squared`: `grad(x^2)` at `x=3.0` → `6.0`
- `grad.matmul`: `grad(a @ b)` compare against numerical gradients
- `grad.softmax`: `grad(softmax(x))` end-to-end
- `grad.multi_consumer`: `x + x` → gradient should be `2.0`
- `cache.hit`: same graph twice → one compile, one cache hit
- `graph.dump`: verify dot output is valid
