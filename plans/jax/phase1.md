# phase 1: pjrt runtime

**goal:** wrap `pkg/jax/pjrt/` into a safe, ergonomic runtime that loads plugins, creates clients, moves data, and executes compiled programs.

## files

| file | purpose |
|------|---------|
| `pkg/jax/runtime/main.zig` | module root |
| `pkg/jax/runtime/plugin.zig` | `plugin` — dlopen + getPjrtApi |
| `pkg/jax/runtime/client.zig` | `client` — wrapper for client_create/devices/etc |
| `pkg/jax/runtime/buffer.zig` | `buffer` — fromHost/toHost/shape/dtype |
| `pkg/jax/runtime/executable.zig` | `executable` — compile + execute + event await |
| `pkg/jax/runtime/test/main.zig` | integration tests |

## plugin.zig

```zig
pub const Plugin = struct {
    lib: std.DynLib,
    api: *const pjrt.Api,

    pub fn init(path: [:0]const u8) !Plugin {
        const lib = try std.DynLib.open(path);
        errdefer lib.close();
        const api = pjrt.getPjrtApi(&lib) orelse return error.NoPjrtApi;
        return Plugin{ .lib = lib, .api = api };
    }

    pub fn deinit(self: *Plugin) void {
        self.lib.close();
    }
};

pub fn availablePlugins(allocator: std.mem.Allocator) ![]const PluginInfo {
    // scan well-known paths for pjrt plugins
    // returns: [{ .name = "cpu", .path = "/usr/lib/pjrt_c_api_cpu_plugin.so" }, ...]
}
```

## client.zig

```zig
pub const Client = struct {
    plugin: *Plugin,
    handle: *pjrt.Client,
    devices: []*pjrt.Device,
    memories: []*pjrt.Memory,

    pub fn init(plugin: *Plugin, options: ClientOptions) !Client
    pub fn deinit(self: *Client) void
    pub fn platformName(self: *const Client) [:0]u8
    pub fn platformVersion(self: *const Client) [:0]u8
    pub fn processIndex(self: *const Client) c_int
    pub fn bufferFromHost(self: *Client, data: anytype, shape: Shape, device: *pjrt.Device, memory: ?*pjrt.Memory) !Buffer
    pub fn compile(self: *Client, program: []const u8, format: [:0]u8, compile_options: []const u8) !LoadedExecutable
    pub fn load(self: *Client, serialized: []const u8, compile_options: []const u8) !LoadedExecutable
};
```

all pjrt errors (`?*error` return) converted to zig errors via `check()`.

## buffer.zig

```zig
pub const Buffer = struct {
    client: *Client,
    handle: *pjrt.Buffer,
    shape: Shape,
    dtype: pjrt.BufferType,

    pub fn fromHost(client: *Client, comptime T: type, data: []const T, dims: []const i64, device: *pjrt.Device, memory: ?*pjrt.Memory) !Buffer
    pub fn toHost(self: *Buffer, comptime T: type, allocator: std.mem.Allocator) ![]T
    pub fn deinit(self: *Buffer) void
    pub fn copyToDevice(self: *Buffer, dst_device: *pjrt.Device) !Buffer
    pub fn onDeviceSize(self: *const Buffer) !usize
    pub fn isOnCpu(self: *const Buffer) !bool
    // shape, dtype, device accessors
};
```

- `fromHost` fills `pjrt.client.BufferFromHostBufferArgs` and calls `client_buffer_from_host_buffer`
- `toHost` calls `buffer_to_host_buffer`, awaits the returned event, copies out

## executable.zig

```zig
pub const LoadedExecutable = struct {
    client: *Client,
    handle: *pjrt.LoadedExecutable,

    pub fn deinit(self: *LoadedExecutable) void
    pub fn execute(self: *LoadedExecutable, args: []const *Buffer, device: ?*pjrt.Device) ![]Buffer
    pub fn addressableDevices(self: *const LoadedExecutable) ![]*pjrt.Device
    pub fn fingerprint(self: *const LoadedExecutable) ![]u8
    pub fn numOutputs(self: *const LoadedExecutable) !usize
    pub fn getExecutable(self: *const LoadedExecutable) !*pjrt.Executable
};
```

- `execute`: fill `LoadedExecuteArgs`, call `loaded_executable_execute`, await all `device_complete_events`, return output buffers
- `compile`: fill `ClientCompileArgs`, call `client_compile`, return `LoadedExecutable`

## build integration

```zig
const jax_runtime_mod = b.addModule("jax-runtime", .{
    .root_source_file = b.path("pkg/jax/runtime/main.zig"),
    .target = target,
    .imports = &.{ .{ .name = "jax", .module = jax_mod } },
});
```

## tests

- `plugin.load_cpu` — load cpu plugin, get api vtable
- `client.create_and_query` — create client, verify `platformName()` contains "cpu"
- `buffer.round_trip` — `[4]f32` host→device→host, values match
- `buffer.shape_query` — verify `onDeviceSize()` is correct
- `exec.compile_and_execute` — compile a trivial stablehlo program (hardcoded bytecode), execute, verify output
