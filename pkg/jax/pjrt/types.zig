const enums = @import("enums.zig");
const handles = @import("handles.zig");

pub const ExtensionType = enums.ExtensionType;
pub const NamedValueType = enums.NamedValueType;
pub const BufferMemoryLayoutType = enums.BufferMemoryLayoutType;
pub const BufferType = enums.BufferType;
pub const HostBufferSemantics = enums.HostBufferSemantics;
pub const ErrorCode = enums.ErrorCode;
pub const ProcessState = enums.ProcessState;

pub const Error = handles.Error;
pub const Client = handles.Client;
pub const Device = handles.Device;
pub const Memory = handles.Memory;
pub const Buffer = handles.Buffer;
pub const Event = handles.Event;
pub const Executable = handles.Executable;
pub const LoadedExecutable = handles.LoadedExecutable;
pub const DeviceDescription = handles.DeviceDescription;
pub const TopologyDescription = handles.TopologyDescription;
pub const ExecuteOptions = handles.ExecuteOptions;
pub const ExecuteContext = handles.ExecuteContext;
pub const SerializedExecutable = handles.SerializedExecutable;
pub const SerializedCompileOptions = handles.SerializedCompileOptions;
pub const AsyncHostToDeviceTransferManager = handles.AsyncHostToDeviceTransferManager;
pub const AsyncTrackingEvent = handles.AsyncTrackingEvent;
pub const FulfillAliasBufferCallback = handles.FulfillAliasBufferCallback;
pub const MultiSliceConfig = handles.MultiSliceConfig;
pub const PhaseCompiler = handles.PhaseCompiler;
pub const CopyToDeviceStream = handles.CopyToDeviceStream;
pub const SerializedTopology = handles.SerializedTopology;
pub const DeviceAttributes = handles.DeviceAttributes;

pub const ExtensionBase = extern struct {
    struct_size: usize,
    type_: ExtensionType,
    next: ?*ExtensionBase,
};

pub const NamedValue = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    name: [*:0]const u8,
    name_size: usize,
    type_: NamedValueType,
    value: extern union {
        string_value: [*:0]const u8,
        int64_value: i64,
        int64_array_value: [*]const i64,
        float_value: f32,
        bool_value: bool,
    },
    value_size: usize,
};

pub const ApiVersion = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    major_version: c_int,
    minor_version: c_int,
};

pub const BufferMemoryLayoutTiled = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    minor_to_major: [*]const i64,
    minor_to_major_size: usize,
    tile_dims: [*]const i64,
    tile_dim_sizes: [*]const usize,
    num_tiles: usize,
};

pub const BufferMemoryLayoutStrides = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    byte_strides: [*]const i64,
    num_byte_strides: usize,
};

pub const BufferMemoryLayout = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    layout: extern union {
        tiled: BufferMemoryLayoutTiled,
        strides: BufferMemoryLayoutStrides,
    },
    type_: BufferMemoryLayoutType,
};

pub const ShapeSpec = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    dims: [*]const i64,
    num_dims: usize,
    element_type: BufferType,
};

pub const Program = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    code: [*]u8,
    code_size: usize,
    format: [*:0]const u8,
    format_size: usize,
};

pub const ProcessInfo = extern struct {
    struct_size: usize,
    task_id: c_int,
    incarnation_id: u64,
    state: ProcessState,
    error_code: c_int,
    error_message: [*:0]const u8,
    error_message_size: usize,
};

pub const SerializedCompileOptions = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    serialized_compile_options: [*:0]const u8,
    serialized_compile_options_size: usize,
};

pub const Chunk = extern struct {
    data: ?*anyopaque,
    size: usize,
    deleter: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void,
    deleter_arg: ?*anyopaque,
};

pub const LogicalDeviceIds = extern struct {
    replica: c_int,
    partition: c_int,
};

pub const ErrorPayloadVisitor = *const fn (key: [*:0]const u8, key_size: usize, value: [*:0]const u8, value_size: usize, user_arg: ?*anyopaque) callconv(.C) void;

pub const CopyRawToHostFutureCallbackArgs = extern struct {
    struct_size: usize,
    callback_data: ?*anyopaque,
    error_code: ErrorCode,
    error_message: [*:0]const u8,
    error_message_size: usize,
    dst: ?*anyopaque,
};

pub const DonateWithControlDependencyCallbackArgs = extern struct {
    struct_size: usize,
    callback_data: ?*anyopaque,
    error_code: ErrorCode,
    error_message: [*:0]const u8,
    error_message_size: usize,
};
