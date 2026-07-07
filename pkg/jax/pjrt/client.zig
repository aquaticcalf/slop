const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const NamedValue = types.NamedValue;
pub const Error = types.Error;
pub const Client = types.Client;
pub const Device = types.Device;
pub const Memory = types.Memory;
pub const Buffer = types.Buffer;
pub const Event = types.Event;
pub const Executable = types.Executable;
pub const LoadedExecutable = types.LoadedExecutable;
pub const TopologyDescription = types.TopologyDescription;
pub const BufferType = types.BufferType;
pub const HostBufferSemantics = types.HostBufferSemantics;
pub const BufferMemoryLayout = types.BufferMemoryLayout;
pub const ShapeSpec = types.ShapeSpec;
pub const AsyncHostToDeviceTransferManager = types.AsyncHostToDeviceTransferManager;
pub const ErrorCode = types.ErrorCode;
pub const ProcessInfo = types.ProcessInfo;
pub const FulfillAliasBufferCallback = types.FulfillAliasBufferCallback;
pub const DeviceAttributes = types.DeviceAttributes;

pub const CreateArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    create_options: ?*const NamedValue,
    num_options: usize,
    kv_get_callback: ?*const fn (?*anyopaque) callconv(.C) ?*Error,
    kv_get_user_arg: ?*anyopaque,
    kv_put_callback: ?*const fn (?*anyopaque) callconv(.C) ?*Error,
    kv_put_user_arg: ?*anyopaque,
    client: ?*Client,
    kv_try_get_callback: ?*const fn (?*anyopaque) callconv(.C) ?*Error,
    kv_try_get_user_arg: ?*anyopaque,
};

pub const DestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
};

pub const PlatformNameArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    platform_name: [*:0]const u8,
    platform_name_size: usize,
};

pub const ProcessIndexArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    process_index: c_int,
};

pub const PlatformVersionArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    platform_version: [*:0]const u8,
    platform_version_size: usize,
};

pub const DevicesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    devices: [*]?*Device,
    num_devices: usize,
};

pub const AddressableDevicesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    addressable_devices: [*]?*Device,
    num_addressable_devices: usize,
};

pub const LookupDeviceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    id: c_int,
    device: ?*Device,
};

pub const LookupAddressableDeviceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    local_hardware_id: c_int,
    addressable_device: ?*Device,
};

pub const AddressableMemoriesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    addressable_memories: [*]?*Memory,
    num_addressable_memories: usize,
};

pub const CompileArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    program: ?*const types.Program,
    compile_options: [*:0]const u8,
    compile_options_size: usize,
    executable: ?*LoadedExecutable,
};

pub const DefaultDeviceAssignmentArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    num_replicas: c_int,
    num_partitions: c_int,
    default_assignment_size: usize,
    default_assignment: [*]c_int,
};

pub const BufferFromHostBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    data: ?*const anyopaque,
    type_: BufferType,
    dims: [*]const i64,
    num_dims: usize,
    byte_strides: [*]const i64,
    num_byte_strides: usize,
    host_buffer_semantics: HostBufferSemantics,
    device: ?*Device,
    memory: ?*Memory,
    device_layout: ?*BufferMemoryLayout,
    done_with_host_buffer: ?*Event,
    buffer: ?*Buffer,
};

pub const TopologyDescriptionArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    topology: ?*TopologyDescription,
};

pub const CreateViewOfDeviceBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    device_buffer_ptr: ?*anyopaque,
    dims: [*]const i64,
    num_dims: usize,
    element_type: BufferType,
    layout: ?*BufferMemoryLayout,
    device: ?*Device,
    on_delete_callback: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void,
    on_delete_callback_arg: ?*anyopaque,
    stream: usize,
    buffer: ?*Buffer,
    memory: ?*Memory,
};

pub const DmaMapArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    data: ?*anyopaque,
    size: usize,
};

pub const DmaUnmapArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    data: ?*anyopaque,
};

pub const LoadArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    executable: ?*Executable,
    compile_options: [*:0]const u8,
    compile_options_size: usize,
    loaded_executable: ?*LoadedExecutable,
};

pub const CreateBuffersForAsyncHostToDeviceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    shape_specs: [*]ShapeSpec,
    num_shape_specs: usize,
    device_layouts: [*]?*BufferMemoryLayout,
    num_device_layouts: usize,
    memory: ?*Memory,
    transfer_manager: ?*AsyncHostToDeviceTransferManager,
};

pub const UpdateGlobalProcessInfoArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    process_info: ?*const ProcessInfo,
};

pub const CreateAliasBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    memory: ?*Memory,
    shape_dims: [*]const i64,
    shape_num_dims: usize,
    shape_element_type: BufferType,
    shape_layout: ?*BufferMemoryLayout,
    alias_buffer: ?*Buffer,
    fulfill_alias_buffer_cb: ?*FulfillAliasBufferCallback,
};

pub const FulfillAliasBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    buffer: ?*Buffer,
    status_code: ErrorCode,
    error_message: [*:0]const u8,
    error_message_size: usize,
    fulfill_alias_buffer_cb: ?*FulfillAliasBufferCallback,
};

pub const CreateErrorBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    @"error": ?*Error,
    buffer: ?*Buffer,
};

pub const CreateUninitializedBufferArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    type_: BufferType,
    dims: [*]const i64,
    num_dims: usize,
    layout: ?*BufferMemoryLayout,
    device: ?*Device,
    buffer: ?*Buffer,
};
