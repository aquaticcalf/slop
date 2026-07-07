const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const AsyncHostToDeviceTransferManager = types.AsyncHostToDeviceTransferManager;
pub const Device = types.Device;
pub const Buffer = types.Buffer;
pub const BufferType = types.BufferType;
pub const BufferMemoryLayout = types.BufferMemoryLayout;
pub const Event = types.Event;
pub const NamedValue = types.NamedValue;
pub const ErrorCode = types.ErrorCode;

pub const DestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
};

pub const TransferDataArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    buffer_index: c_int,
    data: ?*const anyopaque,
    offset: i64,
    transfer_size: i64,
    is_last_transfer: bool,
    done_with_h2d_transfer: ?*Event,
};

pub const RetrieveBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    buffer_index: c_int,
    buffer_out: ?*Buffer,
};

pub const DeviceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    device_out: ?*Device,
};

pub const BufferCountArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    buffer_count: usize,
};

pub const BufferSizeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    buffer_index: c_int,
    buffer_size: usize,
};

pub const SetBufferErrorArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    buffer_index: c_int,
    error_code: ErrorCode,
    error_message: [*:0]const u8,
    error_message_size: usize,
};

pub const AddMetadataArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    transfer_metadata: ?*const NamedValue,
    num_metadata: usize,
};

pub const TransferLiteralArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
    buffer_index: c_int,
    data: ?*const anyopaque,
    shape_dims: [*]const i64,
    shape_num_dims: usize,
    shape_element_type: BufferType,
    shape_layout: ?*BufferMemoryLayout,
    done_with_h2d_transfer: ?*Event,
};
