const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const Device = types.Device;
pub const Memory = types.Memory;
pub const DeviceDescription = types.DeviceDescription;
pub const NamedValue = types.NamedValue;
pub const AsyncTrackingEvent = types.AsyncTrackingEvent;
pub const DeviceAttributes = types.DeviceAttributes;
pub const ErrorCode = types.ErrorCode;

pub const DescriptionIdArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device_description: ?*DeviceDescription,
    id: c_int,
};

pub const DescriptionProcessIndexArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device_description: ?*DeviceDescription,
    process_index: c_int,
};

pub const DescriptionAttributesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device_description: ?*DeviceDescription,
    attributes: ?*const NamedValue,
    num_attributes: usize,
};

pub const DescriptionKindArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device_description: ?*DeviceDescription,
    kind: [*:0]const u8,
    kind_size: usize,
};

pub const DescriptionDebugStringArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device_description: ?*DeviceDescription,
    debug_string: [*:0]const u8,
    debug_string_size: usize,
};

pub const DescriptionToStringArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device_description: ?*DeviceDescription,
    to_string: [*:0]const u8,
    to_string_size: usize,
};

pub const GetDescriptionArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    device_description: ?*DeviceDescription,
};

pub const IsAddressableArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    is_addressable: bool,
};

pub const LocalHardwareIdArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    local_hardware_id: c_int,
};

pub const AddressableMemoriesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    memories: [*]?*Memory,
    num_memories: usize,
};

pub const DefaultMemoryArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    memory: ?*Memory,
};

pub const MemoryIdArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    memory: ?*Memory,
    id: c_int,
};

pub const MemoryKindArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    memory: ?*Memory,
    kind: [*:0]const u8,
    kind_size: usize,
};

pub const MemoryDebugStringArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    memory: ?*Memory,
    debug_string: [*:0]const u8,
    debug_string_size: usize,
};

pub const MemoryToStringArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    memory: ?*Memory,
    to_string: [*:0]const u8,
    to_string_size: usize,
};

pub const MemoryAddressableByDevicesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    memory: ?*Memory,
    devices: [*]?*Device,
    num_devices: usize,
};

pub const MemoryStatsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    bytes_in_use: i64,
    peak_bytes_in_use: i64,
    peak_bytes_in_use_is_set: bool,
    num_allocs: i64,
    num_allocs_is_set: bool,
    largest_alloc_size: i64,
    largest_alloc_size_is_set: bool,
    bytes_limit: i64,
    bytes_limit_is_set: bool,
    bytes_reserved: i64,
    bytes_reserved_is_set: bool,
    peak_bytes_reserved: i64,
    peak_bytes_reserved_is_set: bool,
    bytes_reservable_limit: i64,
    bytes_reservable_limit_is_set: bool,
    largest_free_block_bytes: i64,
    largest_free_block_bytes_is_set: bool,
    pool_bytes: i64,
    pool_bytes_is_set: bool,
    peak_pool_bytes: i64,
    peak_pool_bytes_is_set: bool,
    peak_allocated_bytes: i64,
    peak_allocated_bytes_is_set: bool,
};

pub const PoisonExecutionArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    @"error": ?*types.Error,
};

pub const CreateAsyncTrackingEventArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    event: ?*AsyncTrackingEvent,
};

pub const AsyncTrackingEventDestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*AsyncTrackingEvent,
};

pub const AsyncTrackingEventOnBlockingStartArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*AsyncTrackingEvent,
};

pub const AsyncTrackingEventOnBlockingReadyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    event: ?*AsyncTrackingEvent,
};

pub const GetAttributesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
    attributes: ?*const NamedValue,
    num_attributes: usize,
};

pub const ClearMemoryStatsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    device: ?*Device,
};
