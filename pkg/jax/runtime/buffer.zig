const std = @import("std");
const pjrt = @import("jax").pjrt;
const types = @import("types.zig");
const Client = @import("client.zig").Client;
const check = @import("main.zig").check;

pub const Shape = types.Shape;
pub const DType = types.DType;

pub const Buffer = struct {
    client: *Client,
    handle: *pjrt.Buffer,
    shape: Shape,
    dtype: DType,

    pub fn deinit(self: *Buffer) void {
        const api = self.client.plugin.api;
        var args = pjrt.BufferDestroyArgs{
            .struct_size = @sizeOf(pjrt.BufferDestroyArgs),
            .extension_start = null,
            .buffer = self.handle,
        };
        _ = api.buffer_destroy(&args);
        self.client.allocator.free(self.shape.dims);
    }

    pub fn toHost(self: *Buffer, comptime T: type, allocator: std.mem.Allocator) ![]T {
        const api = self.client.plugin.api;
        const n = self.shape.numElements();
        const buf = try allocator.alloc(T, n);
        errdefer allocator.free(buf);

        var event: ?*pjrt.Event = undefined;
        var args = pjrt.BufferToHostBufferArgs{
            .struct_size = @sizeOf(pjrt.BufferToHostBufferArgs),
            .extension_start = null,
            .src = self.handle,
            .host_layout = null,
            .dst = buf.ptr,
            .dst_size = buf.len * @sizeOf(T),
            .event = @ptrCast(&event),
        };
        try check(api, api.buffer_to_host_buffer(&args));
        const ev = event orelse return error.PjrtError;

        var destroy_args = pjrt.EventDestroyArgs{
            .struct_size = @sizeOf(pjrt.EventDestroyArgs),
            .extension_start = null,
            .event = ev,
        };
        defer _ = api.event_destroy(&destroy_args);

        var await_args = pjrt.EventAwaitArgs{
            .struct_size = @sizeOf(pjrt.EventAwaitArgs),
            .extension_start = null,
            .event = ev,
        };
        try check(api, api.event_await(&await_args));

        var error_args = pjrt.EventErrorArgs{
            .struct_size = @sizeOf(pjrt.EventErrorArgs),
            .extension_start = null,
            .event = ev,
        };
        try check(api, api.event_error(&error_args));
        return buf;
    }

    pub fn onDeviceSize(self: *const Buffer) !usize {
        const api = self.client.plugin.api;
        var args = pjrt.BufferOnDeviceSizeInBytesArgs{
            .struct_size = @sizeOf(pjrt.BufferOnDeviceSizeInBytesArgs),
            .extension_start = null,
            .buffer = self.handle,
            .on_device_size_in_bytes = undefined,
        };
        try check(api, api.buffer_on_device_size_in_bytes(&args));
        return args.on_device_size_in_bytes;
    }

    pub fn isOnCpu(self: *const Buffer) !bool {
        const api = self.client.plugin.api;
        var args = pjrt.BufferIsOnCpuArgs{
            .struct_size = @sizeOf(pjrt.BufferIsOnCpuArgs),
            .extension_start = null,
            .buffer = self.handle,
            .is_on_cpu = undefined,
        };
        try check(api, api.buffer_is_on_cpu(&args));
        return args.is_on_cpu;
    }

    pub fn copyToDevice(self: *Buffer, dst_device: *pjrt.Device) !Buffer {
        const api = self.client.plugin.api;
        var dst_buffer: ?*pjrt.Buffer = undefined;
        var args = pjrt.BufferCopyToDeviceArgs{
            .struct_size = @sizeOf(pjrt.BufferCopyToDeviceArgs),
            .extension_start = null,
            .buffer = self.handle,
            .dst_device = dst_device,
            .dst_buffer = @ptrCast(&dst_buffer),
        };
        try check(api, api.buffer_copy_to_device(&args));
        const dims = try self.client.allocator.alloc(i64, self.shape.dims.len);
        errdefer self.client.allocator.free(dims);
        @memcpy(dims, self.shape.dims);

        return Buffer{
            .client = self.client,
            .handle = dst_buffer orelse return error.PjrtError,
            .shape = Shape{
                .dims = dims,
                .dtype = self.shape.dtype,
            },
            .dtype = self.dtype,
        };
    }

    pub fn device(self: *const Buffer) !?*pjrt.Device {
        const api = self.client.plugin.api;
        var args = pjrt.BufferDeviceArgs{
            .struct_size = @sizeOf(pjrt.BufferDeviceArgs),
            .extension_start = null,
            .buffer = self.handle,
            .device = undefined,
        };
        try check(api, api.buffer_device(&args));
        return args.device;
    }

    pub fn delete(self: *Buffer) !void {
        const api = self.client.plugin.api;
        var args = pjrt.BufferDeleteArgs{
            .struct_size = @sizeOf(pjrt.BufferDeleteArgs),
            .extension_start = null,
            .buffer = self.handle,
        };
        try check(api, api.buffer_delete(&args));
    }

    pub fn isDeleted(self: *const Buffer) !bool {
        const api = self.client.plugin.api;
        var args = pjrt.BufferIsDeletedArgs{
            .struct_size = @sizeOf(pjrt.BufferIsDeletedArgs),
            .extension_start = null,
            .buffer = self.handle,
            .is_deleted = undefined,
        };
        try check(api, api.buffer_is_deleted(&args));
        return args.is_deleted;
    }
};
