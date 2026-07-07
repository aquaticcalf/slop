const enums = @import("enums.zig");
const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const Event = types.Event;
pub const Error = types.Error;
pub const ErrorCode = enums.ErrorCode;

pub const EventDestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
};

pub const EventIsReadyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
    is_ready: bool,
};

pub const EventErrorArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
};

pub const EventAwaitArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
};

pub const EventOnReadyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
    callback: *const fn (?*Error, ?*anyopaque) callconv(.C) void,
    user_arg: ?*anyopaque,
};

pub const EventCreateArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
};

pub const EventArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*Event,
    error_code: ErrorCode,
    error_message: [*:0]const u8,
    error_message_size: usize,
};
