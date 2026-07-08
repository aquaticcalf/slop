const std = @import("std");
const pjrt = @import("jax").pjrt;
const types = @import("types.zig");
const Buffer = @import("buffer.zig").Buffer;
const Client = @import("client.zig").Client;
const check = @import("main.zig").check;

pub const Shape = types.Shape;
pub const DType = types.DType;

pub const LoadedExecutable = struct {
    client: *Client,
    handle: *pjrt.LoadedExecutable,

    pub fn deinit(self: *LoadedExecutable) void {
        const api = self.client.plugin.api;
        var args = pjrt.LoadedExecutableDestroyArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableDestroyArgs),
            .extension_start = null,
            .loaded_executable = self.handle,
        };
        _ = api.loaded_executable_destroy(&args);
    }

    pub fn execute(
        self: *LoadedExecutable,
        args: []const *Buffer,
        device: ?*pjrt.Device,
        allocator: std.mem.Allocator,
    ) ![]Buffer {
        const api = self.client.plugin.api;
        const devs = try self.addressableDevices(allocator);
        defer allocator.free(devs);
        if (devs.len == 0) return error.NoDevices;
        const exec_device = device orelse devs[0];

        const n_devices: usize = 1;
        const n_args = args.len;
        const n_outputs = try self.numOutputs();

        var device_args = try allocator.alloc(?*pjrt.Buffer, n_args);
        defer allocator.free(device_args);
        for (args, 0..) |buf, i| device_args[i] = buf.handle;

        var arg_lists = try allocator.alloc([*]?*pjrt.Buffer, n_devices);
        defer allocator.free(arg_lists);
        arg_lists[0] = device_args.ptr;

        const output_lists = try allocator.alloc([*]?*pjrt.Buffer, n_devices);
        defer allocator.free(output_lists);
        for (output_lists) |*ol| {
            const slice = try allocator.alloc(?*pjrt.Buffer, n_outputs);
            @memset(slice, null);
            ol.* = slice.ptr;
        }
        defer for (output_lists) |ol| allocator.free(ol[0..n_outputs]);

        const events = try allocator.alloc(?*pjrt.Event, n_devices);
        defer allocator.free(events);
        @memset(events, null);

        var exec_args = pjrt.LoadedExecutableExecuteArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableExecuteArgs),
            .extension_start = null,
            .executable = self.handle,
            .options = null,
            .argument_lists = arg_lists.ptr,
            .num_devices = n_devices,
            .num_args = n_args,
            .output_lists = output_lists.ptr,
            .device_complete_events = events.ptr,
            .execute_device = exec_device,
        };
        try check(api, api.loaded_executable_execute(&exec_args));

        defer {
            for (events) |ev| {
                if (ev) |event| {
                    var destroy_args = pjrt.EventDestroyArgs{
                        .struct_size = @sizeOf(pjrt.EventDestroyArgs),
                        .extension_start = null,
                        .event = event,
                    };
                    _ = api.event_destroy(&destroy_args);
                }
            }
        }

        errdefer {
            for (output_lists[0][0..n_outputs]) |bh| {
                if (bh) |handle| {
                    var destroy_buf_args = pjrt.BufferDestroyArgs{
                        .struct_size = @sizeOf(pjrt.BufferDestroyArgs),
                        .extension_start = null,
                        .buffer = handle,
                    };
                    _ = api.buffer_destroy(&destroy_buf_args);
                }
            }
        }

        for (events) |ev| {
            const event = ev orelse return error.PjrtError;
            var await_args = pjrt.EventAwaitArgs{
                .struct_size = @sizeOf(pjrt.EventAwaitArgs),
                .extension_start = null,
                .event = event,
            };
            try check(api, api.event_await(&await_args));
        }

        const out_handles = output_lists[0];
        var result = try allocator.alloc(Buffer, n_outputs);
        errdefer allocator.free(result);

        var initialized_count: usize = 0;
        errdefer {
            for (result[0..initialized_count]) |*b| b.deinit();
        }

        for (0..n_outputs) |i| {
            const bh = out_handles[i] orelse return error.PjrtError;

            var type_args = pjrt.BufferElementTypeArgs{
                .struct_size = @sizeOf(pjrt.BufferElementTypeArgs),
                .extension_start = null,
                .buffer = bh,
                .type_ = undefined,
            };
            try check(api, api.buffer_element_type(&type_args));
            const dtype = DType.fromBufferType(type_args.type_);

            var dim_args = pjrt.BufferDimensionsArgs{
                .struct_size = @sizeOf(pjrt.BufferDimensionsArgs),
                .extension_start = null,
                .buffer = bh,
                .dims = undefined,
                .num_dims = undefined,
            };
            try check(api, api.buffer_dimensions(&dim_args));

            const dims = try self.client.allocator.alloc(i64, dim_args.num_dims);
            @memcpy(dims, dim_args.dims[0..dim_args.num_dims]);

            result[i] = Buffer{
                .client = self.client,
                .handle = bh,
                .shape = Shape{
                    .dims = dims,
                    .dtype = dtype,
                },
                .dtype = dtype,
            };
            initialized_count += 1;
        }
        return result;
    }

    pub fn addressableDevices(self: *const LoadedExecutable, allocator: std.mem.Allocator) ![]*pjrt.Device {
        const api = self.client.plugin.api;
        var args = pjrt.LoadedExecutableAddressableDevicesArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableAddressableDevicesArgs),
            .extension_start = null,
            .loaded_executable = self.handle,
            .addressable_devices = undefined,
            .num_addressable_devices = undefined,
        };
        try check(api, api.loaded_executable_addressable_devices(&args));
        const result = try allocator.alloc(*pjrt.Device, args.num_addressable_devices);
        for (0..args.num_addressable_devices) |i| {
            result[i] = args.addressable_devices[i] orelse return error.PjrtError;
        }
        return result;
    }

    pub fn fingerprint(self: *const LoadedExecutable, allocator: std.mem.Allocator) ![]u8 {
        const api = self.client.plugin.api;
        var args = pjrt.LoadedExecutableFingerprintArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableFingerprintArgs),
            .extension_start = null,
            .executable = self.handle,
            .executable_fingerprint = undefined,
            .executable_fingerprint_size = undefined,
        };
        try check(api, api.loaded_executable_fingerprint(&args));
        return try allocator.dupe(u8, args.executable_fingerprint[0..args.executable_fingerprint_size]);
    }

    pub fn numOutputs(self: *const LoadedExecutable) !usize {
        const api = self.client.plugin.api;
        var args = pjrt.ExecutableNumOutputsArgs{
            .struct_size = @sizeOf(pjrt.ExecutableNumOutputsArgs),
            .extension_start = null,
            .executable = @ptrCast(self.handle),
            .num_outputs = undefined,
        };
        try check(api, api.executable_num_outputs(&args));
        return args.num_outputs;
    }

    pub fn getExecutable(self: *const LoadedExecutable) !*pjrt.Executable {
        const api = self.client.plugin.api;
        var exec: ?*pjrt.Executable = undefined;
        var args = pjrt.LoadedExecutableGetExecutableArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableGetExecutableArgs),
            .extension_start = null,
            .loaded_executable = self.handle,
            .executable = @ptrCast(&exec),
        };
        try check(api, api.loaded_executable_get_executable(&args));
        return exec orelse return error.PjrtError;
    }

    pub fn delete(self: *LoadedExecutable) !void {
        const api = self.client.plugin.api;
        var args = pjrt.LoadedExecutableDeleteArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableDeleteArgs),
            .extension_start = null,
            .loaded_executable = self.handle,
        };
        try check(api, api.loaded_executable_delete(&args));
    }

    pub fn isDeleted(self: *const LoadedExecutable) !bool {
        const api = self.client.plugin.api;
        var args = pjrt.LoadedExecutableIsDeletedArgs{
            .struct_size = @sizeOf(pjrt.LoadedExecutableIsDeletedArgs),
            .extension_start = null,
            .loaded_executable = self.handle,
            .is_deleted = undefined,
        };
        try check(api, api.loaded_executable_is_deleted(&args));
        return args.is_deleted;
    }
};
