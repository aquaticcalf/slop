const std = @import("std");
const pjrt = @import("jax").pjrt;
const types = @import("types.zig");
const Plugin = @import("plugin.zig").Plugin;
const Buffer = @import("buffer.zig").Buffer;
const LoadedExecutable = @import("executable.zig").LoadedExecutable;
const check = @import("main.zig").check;

pub const Shape = types.Shape;
pub const DType = types.DType;

pub const Client = struct {
    plugin: *Plugin,
    handle: *pjrt.Client,
    devices: []*pjrt.Device,
    memories: []*pjrt.Memory,
    allocator: std.mem.Allocator,

    pub fn init(plugin: *Plugin, allocator: std.mem.Allocator) !Client {
        var args = pjrt.ClientCreateArgs{
            .struct_size = @sizeOf(pjrt.ClientCreateArgs),
            .extension_start = null,
            .create_options = null,
            .num_options = 0,
            .kv_get_callback = null,
            .kv_get_user_arg = null,
            .kv_put_callback = null,
            .kv_put_user_arg = null,
            .client = undefined,
            .kv_try_get_callback = null,
            .kv_try_get_user_arg = null,
        };
        try check(plugin.api, plugin.api.client_create(&args));
        const handle = args.client orelse return error.PjrtError;

        var dev_args = pjrt.ClientDevicesArgs{
            .struct_size = @sizeOf(pjrt.ClientDevicesArgs),
            .extension_start = null,
            .client = handle,
            .devices = undefined,
            .num_devices = undefined,
        };
        try check(plugin.api, plugin.api.client_devices(&dev_args));
        const devices = try allocator.alloc(*pjrt.Device, dev_args.num_devices);
        errdefer allocator.free(devices);
        for (0..dev_args.num_devices) |i| {
            devices[i] = dev_args.devices[i] orelse return error.PjrtError;
        }

        var mem_args = pjrt.ClientAddressableMemoriesArgs{
            .struct_size = @sizeOf(pjrt.ClientAddressableMemoriesArgs),
            .extension_start = null,
            .client = handle,
            .addressable_memories = undefined,
            .num_addressable_memories = undefined,
        };
        try check(plugin.api, plugin.api.client_addressable_memories(&mem_args));
        const memories = try allocator.alloc(*pjrt.Memory, mem_args.num_addressable_memories);
        errdefer allocator.free(memories);
        for (0..mem_args.num_addressable_memories) |i| {
            memories[i] = mem_args.addressable_memories[i] orelse return error.PjrtError;
        }

        return Client{
            .plugin = plugin,
            .handle = handle,
            .devices = devices,
            .memories = memories,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Client) void {
        var args = pjrt.ClientDestroyArgs{
            .struct_size = @sizeOf(pjrt.ClientDestroyArgs),
            .extension_start = null,
            .client = self.handle,
        };
        _ = self.plugin.api.client_destroy(&args);
        self.allocator.free(self.devices);
        self.allocator.free(self.memories);
    }

    pub fn platformName(self: *const Client) ![:0]const u8 {
        var args = pjrt.ClientPlatformNameArgs{
            .struct_size = @sizeOf(pjrt.ClientPlatformNameArgs),
            .extension_start = null,
            .client = self.handle,
            .platform_name = undefined,
            .platform_name_size = undefined,
        };
        try check(self.plugin.api, self.plugin.api.client_platform_name(&args));
        return std.mem.span(args.platform_name);
    }

    pub fn platformVersion(self: *const Client) ![:0]const u8 {
        var args = pjrt.ClientPlatformVersionArgs{
            .struct_size = @sizeOf(pjrt.ClientPlatformVersionArgs),
            .extension_start = null,
            .client = self.handle,
            .platform_version = undefined,
            .platform_version_size = undefined,
        };
        try check(self.plugin.api, self.plugin.api.client_platform_version(&args));
        return std.mem.span(args.platform_version);
    }

    pub fn processIndex(self: *const Client) !c_int {
        var args = pjrt.ClientProcessIndexArgs{
            .struct_size = @sizeOf(pjrt.ClientProcessIndexArgs),
            .extension_start = null,
            .client = self.handle,
            .process_index = undefined,
        };
        try check(self.plugin.api, self.plugin.api.client_process_index(&args));
        return args.process_index;
    }

    pub fn bufferFromHost(
        self: *Client,
        comptime T: type,
        data: []const T,
        shape: Shape,
        device: *pjrt.Device,
        memory: ?*pjrt.Memory,
    ) !Buffer {
        const dims = try self.allocator.alloc(i64, shape.dims.len);
        errdefer self.allocator.free(dims);
        @memcpy(dims, shape.dims);

        var buffer_out: ?*pjrt.Buffer = undefined;
        var done_event: ?*pjrt.Event = undefined;
        var args = pjrt.ClientBufferFromHostBufferArgs{
            .struct_size = @sizeOf(pjrt.ClientBufferFromHostBufferArgs),
            .extension_start = null,
            .client = self.handle,
            .data = data.ptr,
            .type_ = shape.dtype.toBufferType(),
            .dims = shape.dims.ptr,
            .num_dims = shape.dims.len,
            .byte_strides = undefined,
            .num_byte_strides = 0,
            .host_buffer_semantics = .immutable_until_transfer_completes,
            .device = device,
            .memory = memory,
            .device_layout = null,
            .done_with_host_buffer = @ptrCast(&done_event),
            .buffer = @ptrCast(&buffer_out),
        };
        try check(self.plugin.api, self.plugin.api.client_buffer_from_host_buffer(&args));
        const buf_handle = buffer_out orelse return error.PjrtError;

        return Buffer{
            .client = self,
            .handle = buf_handle,
            .shape = Shape{
                .dims = dims,
                .dtype = shape.dtype,
            },
            .dtype = shape.dtype,
        };
    }

    pub fn compile(
        self: *Client,
        program: []const u8,
        format: [:0]const u8,
        compile_options: []const u8,
    ) !LoadedExecutable {
        var loaded: ?*pjrt.LoadedExecutable = undefined;
        var prog = pjrt.Program{
            .struct_size = @sizeOf(pjrt.Program),
            .extension_start = null,
            .code = @constCast(program.ptr),
            .code_size = program.len,
            .format = format,
            .format_size = format.len,
        };
        var args = pjrt.ClientCompileArgs{
            .struct_size = @sizeOf(pjrt.ClientCompileArgs),
            .extension_start = null,
            .client = self.handle,
            .program = &prog,
            .compile_options = @ptrCast(compile_options.ptr),
            .compile_options_size = compile_options.len,
            .executable = @ptrCast(&loaded),
        };
        try check(self.plugin.api, self.plugin.api.client_compile(&args));
        return LoadedExecutable{
            .client = self,
            .handle = loaded orelse return error.PjrtError,
        };
    }

    pub fn deserializeAndLoad(self: *Client, serialized: []const u8, compile_options: []const u8) !LoadedExecutable {
        var loaded: ?*pjrt.LoadedExecutable = undefined;
        var args = pjrt.ExecutableDeserializeAndLoadArgs{
            .struct_size = @sizeOf(pjrt.ExecutableDeserializeAndLoadArgs),
            .extension_start = null,
            .client = self.handle,
            .serialized_executable = @ptrCast(serialized.ptr),
            .serialized_executable_size = serialized.len,
            .loaded_executable = @ptrCast(&loaded),
            .overridden_serialized_compile_options = @ptrCast(compile_options.ptr),
            .overridden_serialized_compile_options_size = compile_options.len,
            .load_options = null,
        };
        try check(self.plugin.api, self.plugin.api.executable_deserialize_and_load(&args));
        return LoadedExecutable{
            .client = self,
            .handle = loaded orelse return error.PjrtError,
        };
    }
};
