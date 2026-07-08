const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const Buffer = types.Buffer;
pub const Event = types.Event;
pub const Device = types.Device;
pub const Memory = types.Memory;
pub const Error = types.Error;
pub const BufferType = types.BufferType;
pub const BufferMemoryLayout = types.BufferMemoryLayout;
pub const ErrorCode = types.ErrorCode;
pub const CopyRawToHostFutureCallbackArgs = types.CopyRawToHostFutureCallbackArgs;
pub const DonateWithControlDependencyCallbackArgs = types.DonateWithControlDependencyCallbackArgs;

pub const DestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
};

pub const ElementTypeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    type_: BufferType,
};

pub const DimensionsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    dims: [*]const i64,
    num_dims: usize,
};

pub const OnDeviceSizeInBytesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    on_device_size_in_bytes: usize,
};

pub const CopyRawToHostFutureArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    dst: ?*anyopaque,
    callback: ?*const fn (?*CopyRawToHostFutureCallbackArgs) callconv(.c) void,
    callback_data: ?*anyopaque,
};

pub const DonateWithControlDependencyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    callback: ?*const fn (?*DonateWithControlDependencyCallbackArgs) callconv(.c) void,
    callback_data: ?*anyopaque,
};

pub const BitcastArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    type_: BufferType,
    dims: [*]const i64,
    num_dims: usize,
    layout: ?*const BufferMemoryLayout,
    output: ?*Buffer,
};

pub const DeviceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    device: ?*Device,
};

pub const MemoryArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    memory: ?*Memory,
};

pub const DeleteArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
};

pub const IsDeletedArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    is_deleted: bool,
};

pub const CopyToDeviceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    dst_device: ?*Device,
    dst_buffer: ?*Buffer,
};

pub const ToHostBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    src: ?*Buffer,
    host_layout: ?*BufferMemoryLayout,
    dst: ?*anyopaque,
    dst_size: usize,
    event: ?*Event,
};

pub const IsOnCpuArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    is_on_cpu: bool,
};

pub const ReadyEventArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    event: ?*Event,
};

pub const UnsafePointerArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    unsafe_pointer: ?*anyopaque,
};

pub const OpaqueDeviceMemoryDataPointerArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    opaque_device_memory_data_pointer: ?*anyopaque,
};

pub const GetMemoryLayoutArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    layout: ?*BufferMemoryLayout,
};

pub const CopyRawToHostArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    buffer: ?*Buffer,
    dst: ?*anyopaque,
    offset: i64,
    transfer_size: i64,
    event: ?*Event,
};
