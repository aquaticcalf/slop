const std = @import("std");
const pjrt = @import("jax").pjrt;

pub const types = @import("types.zig");
pub const plugin = @import("plugin.zig");
pub const client = @import("client.zig");
pub const buffer = @import("buffer.zig");
pub const executable = @import("executable.zig");

pub const DType = types.DType;
pub const Shape = types.Shape;
pub const Plugin = plugin.Plugin;
pub const Client = client.Client;
pub const Buffer = buffer.Buffer;
pub const LoadedExecutable = executable.LoadedExecutable;

pub const PjrtError = error{PjrtError};

pub fn check(api: *const pjrt.Api, maybe_err: ?*pjrt.Error) PjrtError!void {
    const err = maybe_err orelse return;
    var destroy_args = pjrt.ErrorDestroyArgs{
        .struct_size = @sizeOf(pjrt.ErrorDestroyArgs),
        .extension_start = null,
        .@"error" = err,
    };
    defer _ = api.error_destroy(&destroy_args);
    var msg_args = pjrt.ErrorMessageArgs{
        .struct_size = @sizeOf(pjrt.ErrorMessageArgs),
        .extension_start = null,
        .@"error" = err,
        .message = undefined,
        .message_size = undefined,
    };
    _ = api.error_message(&msg_args);
    const msg = msg_args.message[0..msg_args.message_size];
    std.log.err("PJRT error: {s}", .{msg});
    return error.PjrtError;
}
