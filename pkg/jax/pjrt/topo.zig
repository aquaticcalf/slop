const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const TopologyDescription = types.TopologyDescription;
pub const NamedValue = types.NamedValue;
pub const DeviceDescription = types.DeviceDescription;
pub const SerializedTopology = types.SerializedTopology;
pub const BufferType = types.BufferType;
pub const BufferMemoryLayout = types.BufferMemoryLayout;

pub const CreateArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology_name: [*:0]const u8,
    topology_name_size: usize,
    create_options: ?*const NamedValue,
    num_options: usize,
    topology: ?*TopologyDescription,
};

pub const DestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*TopologyDescription,
};

pub const PlatformNameArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*const TopologyDescription,
    platform_name: [*:0]const u8,
    platform_name_size: usize,
};

pub const PlatformVersionArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*TopologyDescription,
    platform_version: [*:0]const u8,
    platform_version_size: usize,
};

pub const GetDeviceDescriptionsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*const TopologyDescription,
    descriptions: [*]?*const DeviceDescription,
    num_descriptions: usize,
};

pub const SerializeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*TopologyDescription,
    serialized_bytes: [*:0]const u8,
    serialized_bytes_size: usize,
    serialized_topology: ?*SerializedTopology,
    serialized_topology_deleter: ?*const fn (?*SerializedTopology) callconv(.C) void,
};

pub const DeserializeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    serialized_topology: [*:0]const u8,
    serialized_topology_size: usize,
    topology: ?*TopologyDescription,
};

pub const AttributesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*TopologyDescription,
    attributes: ?*const NamedValue,
    num_attributes: usize,
};

pub const FingerprintArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*const TopologyDescription,
    fingerprint: u64,
};

pub const MakeCanonicalShapeForMemorySpaceArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*const TopologyDescription,
    memory_space_kind_id: c_int,
    dims: [*]const i64,
    num_dims: usize,
    element_type: BufferType,
    layout: ?*const BufferMemoryLayout,
    serialized_shape: [*:0]const u8,
    serialized_shape_size: usize,
    serialized_shape_deleter: ?*const fn ([*:0]const u8) callconv(.C) void,
};

pub const GetMemorySpaceKindIdsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*const TopologyDescription,
    memory_space_kind_ids: [*]const c_int,
    num_memory_space_kind_ids: usize,
};
