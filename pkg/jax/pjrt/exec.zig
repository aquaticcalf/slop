const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const Executable = types.Executable;
pub const LoadedExecutable = types.LoadedExecutable;
pub const Client = types.Client;
pub const Device = types.Device;
pub const Buffer = types.Buffer;
pub const Event = types.Event;
pub const SerializedExecutable = types.SerializedExecutable;
pub const ExecuteOptions = types.ExecuteOptions;
pub const NamedValue = types.NamedValue;
pub const MultiSliceConfig = types.MultiSliceConfig;
pub const TopologyDescription = types.TopologyDescription;
pub const Program = types.Program;
pub const ExecuteContext = types.ExecuteContext;
pub const BufferType = types.BufferType;
pub const BufferMemoryLayout = types.BufferMemoryLayout;
pub const Memory = types.Memory;
pub const LogicalDeviceIds = types.LogicalDeviceIds;
pub const SerializedCompileOptions = types.SerializedCompileOptions;

pub const DestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
};

pub const NameArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    name: [*:0]const u8,
    name_size: usize,
};

pub const NumReplicasArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    num_replicas: c_int,
};

pub const NumPartitionsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    num_partitions: c_int,
};

pub const NumOutputsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    num_outputs: usize,
};

pub const SizeOfGeneratedCodeInBytesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    size_in_bytes: i64,
};

pub const SerializeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*const Executable,
    serialized_bytes: [*:0]const u8,
    serialized_bytes_size: usize,
    serialized_executable: ?*SerializedExecutable,
    serialized_executable_deleter: ?*const fn (?*SerializedExecutable) callconv(.C) void,
};

pub const DeserializeAndLoadArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    client: ?*Client,
    serialized_executable: [*:0]const u8,
    serialized_executable_size: usize,
    loaded_executable: ?*LoadedExecutable,
    overridden_serialized_compile_options: [*:0]const u8,
    overridden_serialized_compile_options_size: usize,
    load_options: ?*anyopaque,
};

pub const FingerprintArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    executable_fingerprint: [*:0]const u8,
    executable_fingerprint_size: usize,
};

pub const GetCostAnalysisArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    num_properties: usize,
    properties: ?*const NamedValue,
};

pub const OutputMemoryKindsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    num_outputs: usize,
    memory_kinds: [*][*:0]const u8,
    memory_kind_sizes: [*]const usize,
};

pub const GetCompiledMemoryStatsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*Executable,
    generated_code_size_in_bytes: i64,
    argument_size_in_bytes: i64,
    output_size_in_bytes: i64,
    alias_size_in_bytes: i64,
    temp_size_in_bytes: i64,
    host_generated_code_size_in_bytes: i64,
    host_argument_size_in_bytes: i64,
    host_output_size_in_bytes: i64,
    host_alias_size_in_bytes: i64,
    host_temp_size_in_bytes: i64,
};

pub const LoadedDestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    loaded_executable: ?*LoadedExecutable,
};

pub const LoadedGetExecutableArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    loaded_executable: ?*LoadedExecutable,
    executable: ?*Executable,
};

pub const LoadedAddressableDevicesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    loaded_executable: ?*LoadedExecutable,
    addressable_devices: [*]?*Device,
    num_addressable_devices: usize,
};

pub const LoadedDeleteArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    loaded_executable: ?*LoadedExecutable,
};

pub const LoadedIsDeletedArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    loaded_executable: ?*LoadedExecutable,
    is_deleted: bool,
};

pub const LoadedExecuteArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    options: ?*ExecuteOptions,
    argument_lists: [*]const [*]?*Buffer,
    num_devices: usize,
    num_args: usize,
    output_lists: [*][*]?*Buffer,
    device_complete_events: [*]?*Event,
    execute_device: ?*Device,
};

pub const LoadedFingerprintArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    executable_fingerprint: [*:0]const u8,
    executable_fingerprint_size: usize,
};

pub const LoadedGetDeviceAssignmentArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    device_assignment: [*]c_int,
    device_assignment_size: usize,
};

pub const LoadOptions = extern struct {
    struct_size: usize,
    computation_origin: [*]const i32,
    computation_origin_size: usize,
    multi_slice_config: ?*MultiSliceConfig,
};

pub const CompileArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    topology: ?*const TopologyDescription,
    program: ?*const Program,
    compile_options: [*:0]const u8,
    compile_options_size: usize,
    client: ?*Client,
    executable: ?*Executable,
};

pub const ExecuteContextCreateArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    context: ?*ExecuteContext,
};

pub const ExecuteContextDestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    context: ?*ExecuteContext,
};

pub const OutputElementTypesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    output_element_types: [*]BufferType,
    num_output_element_types: usize,
};

pub const OutputDimensionsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    output_dimensions: [*][*]i64,
    num_outputs: usize,
    num_dims: [*]usize,
};

pub const GetCompileOptionsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    compile_options: ?*SerializedCompileOptions,
};

pub const ParameterMemoryKindsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    parameter_memory_kinds: [*][*:0]const u8,
    num_parameters: usize,
    num_memory_kinds: [*]usize,
};

pub const AddressableDeviceLogicalIdsArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    executable: ?*LoadedExecutable,
    addressable_device_logical_ids: [*]LogicalDeviceIds,
    num_addressable_devices: usize,
};
