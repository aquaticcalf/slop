const enums = @import("enums.zig");
const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const Error = types.Error;
pub const ErrorCode = enums.ErrorCode;
pub const NamedValue = types.NamedValue;
pub const ErrorPayloadVisitor = types.ErrorPayloadVisitor;

pub const ErrorDestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    @"error": ?*Error,
};

pub const ErrorMessageArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    @"error": ?*const Error,
    message: [*:0]const u8,
    message_size: usize,
};

pub const ErrorGetCodeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    @"error": ?*const Error,
    code: ErrorCode,
};

pub const PluginInitializeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
};

pub const PluginAttributesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    attributes: ?*const NamedValue,
    num_attributes: usize,
};

pub const ForEachPayloadArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    @"error": ?*Error,
    visitor: ErrorPayloadVisitor,
    user_arg: ?*anyopaque,
};
