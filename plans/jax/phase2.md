# phase 2: stablehlo ir construction

**goal:** programmatically build stablehlo programs from zig that can be compiled by pjrt.

**depends on:** phase 1

## approach

not shelling out to `stablehlo-opt`. create zig bindings for the **stablehlo c api** (`stablehlo_c_api.h`), which lets us build stablehlo ops programmatically in-process.

the stablehlo c api wraps the mlir c api internally — we link `libstablehlo.so`.

## building stablehlo from source

clone and build the stablehlo repo:

```
git clone https://github.com/openxla/stablehlo.git
cd stablehlo
cmake -G "Ninja" -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DSTABLEHLO_ENABLE_BINDINGS_PYTHON=OFF \
  -DMLIR_DIR=external/llvm-project/mlir/lib/cmake/mlir
cmake --build build --target stablehlo-c-api
```

this produces `libstablehlo.so` (or `.dylib`/`.lib` depending on platform). the build also produces the `stablehlo_c_api.h` header under `build/stablehlo_c_api/`.

alternatively, mlir can be built separately and pointed at via `MLIR_DIR`. for ci, cache the build artifact.

for zig integration, the lib search path is set in `build.zig` via `b.addLibraryPath()` and `b.linkSystemLibrary()`, or by passing the path at build time.

## files

| file | purpose |
|------|---------|
| `pkg/jax/hlo/main.zig` | module root |
| `pkg/jax/hlo/builder.zig` | ir builder — ops → stablehlo program |
| `pkg/jax/hlo/ops.zig` | per-op implementations |
| `pkg/jax/hlo/types.zig` | `shape`, `dtype`, `hlovalue` |
| `pkg/jax/hlo/c_api.zig` | stablehlo c api bindings (thin) |
| `pkg/jax/hlo/test/main.zig` | tests |

## c_api.zig — stablehlo c api bindings

thin `extern fn` declarations:

```zig
pub const MlirContext = opaque {};
pub const MlirModule = opaque {};
pub const MlirOperation = opaque {};
pub const MlirValue = opaque {};
pub const MlirBlock = opaque {};
pub const MlirLocation = opaque {};
pub const MlirAttribute = opaque {};
pub const MlirType = opaque {};
pub const MlirIdentifier = opaque {};
pub const MlirStringRef = extern struct { data: [*]const u8, length: usize };

pub extern fn mlirContextCreate() *MlirContext;
pub extern fn mlirContextDestroy(context: *MlirContext) void;
pub extern fn mlirModuleCreateEmpty(location: MlirLocation) *MlirModule;
// ... ~50 more mlir-c api functions needed
```

then stablehlo-specific ops:

```zig
pub extern fn stablehloAddOp(...) *MlirOperation;
pub extern fn stablehloMultiplyOp(...) *MlirOperation;
pub extern fn stablehloDotGeneralOp(...) *MlirOperation;
pub extern fn stablehloReduceOp(...) *MlirOperation;
// ... one per stablehlo op we need
```

## builder.zig — ir builder

```zig
pub const Builder = struct {
    context: *MlirContext,
    module: *MlirModule,
    body: MlirBlock,
    values: std.ArrayListUnmanaged(HloValue),

    pub fn init(allocator: std.mem.Allocator) !Builder
    pub fn deinit(self: *Builder) void

    pub fn parameter(self: *Builder, shape: Shape, name: []const u8) HloValue
    pub fn constant(self: *Builder, comptime T: type, data: []const T, shape: Shape) HloValue
    pub fn add(self: *Builder, a: HloValue, b: HloValue) HloValue
    pub fn multiply(self: *Builder, a: HloValue, b: HloValue) HloValue
    pub fn dotGeneral(self: *Builder, a: HloValue, b: HloValue, config: DotConfig) HloValue
    // ... one method per op

    pub fn build(self: *Builder) ![]u8  // serialize to bytecode
    pub fn dump(self: *Builder) void    // print mlir text for debugging
};
```

## types.zig — core types

```zig
pub const DType = enum {
    f32, f16, bf16,
    i32, i64, u32, u64,
    bool, s8, u8, s16, u16, s4, u4,
    token,

    pub fn toBufferType(self: DType) pjrt.BufferType { ... }
    pub fn sizeInBytes(self: DType) usize { ... }
};

pub const Shape = struct {
    dims: []const i64,
    dtype: DType,

    pub fn numElements(self: Shape) usize { ... }
    pub fn sizeInBytes(self: Shape) usize { ... }
};

pub const HloValue = struct {
    inner: MlirValue,
    shape: Shape,
};
```

## minimum op set for llm training

**elementwise:** `add`, `multiply`, `subtract`, `divide`, `negate`, `exp`, `log`, `tanh`, `rsqrt`, `ceil`, `floor`, `abs`, `sign`, `max`, `min`, `compare`
**reduction:** `reduce` (sum, max, min), `reduce_window` (max for pooling)
**tensor:** `dot_general`, `transpose`, `reshape`, `broadcast_in_dim`, `concatenate`, `slice`, `pad`, `reverse`, `gather`, `scatter`
**control:** `select`, `iota`, `constant`, `convert`, `custom_call`

## tests

- build `x * y + x`, serialize to bytecode, compile via pjrt cpu plugin, execute, verify
- build `dot_general([2,3], [3,4])`, compile, execute, verify against known matmul result
- build `reduce_sum([2,3], axis=1)`, verify
- each op: correct mlir text in `dump()`, correct bytecode, correct execution result
