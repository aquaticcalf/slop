const std = @import("std");
const types = @import("types.zig");
const errors = @import("errors.zig");
const events = @import("events.zig");
const client = @import("client.zig");
const device = @import("device.zig");
const exec = @import("exec.zig");
const buffer = @import("buffer.zig");
const stream = @import("stream.zig");
const topo = @import("topo.zig");
const transfer = @import("transfer.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const ApiVersion = types.ApiVersion;
pub const Error = types.Error;
pub const Client = types.Client;
pub const Buffer = types.Buffer;
pub const Event = types.Event;
pub const Device = types.Device;
pub const Memory = types.Memory;
pub const Executable = types.Executable;
pub const LoadedExecutable = types.LoadedExecutable;

pub const ErrorDestroyArgs = errors.ErrorDestroyArgs;
pub const ErrorMessageArgs = errors.ErrorMessageArgs;
pub const ErrorGetCodeArgs = errors.ErrorGetCodeArgs;
pub const PluginInitializeArgs = errors.PluginInitializeArgs;
pub const PluginAttributesArgs = errors.PluginAttributesArgs;
pub const EventDestroyArgs = events.EventDestroyArgs;
pub const EventIsReadyArgs = events.EventIsReadyArgs;
pub const EventErrorArgs = events.EventErrorArgs;
pub const EventAwaitArgs = events.EventAwaitArgs;
pub const EventOnReadyArgs = events.EventOnReadyArgs;
pub const EventCreateArgs = events.EventCreateArgs;
pub const EventArgs = events.EventArgs;
pub const ClientCreateArgs = client.CreateArgs;
pub const ClientDestroyArgs = client.DestroyArgs;
pub const ClientPlatformNameArgs = client.PlatformNameArgs;
pub const ClientProcessIndexArgs = client.ProcessIndexArgs;
pub const ClientPlatformVersionArgs = client.PlatformVersionArgs;
pub const ClientDevicesArgs = client.DevicesArgs;
pub const ClientAddressableDevicesArgs = client.AddressableDevicesArgs;
pub const ClientLookupDeviceArgs = client.LookupDeviceArgs;
pub const ClientLookupAddressableDeviceArgs = client.LookupAddressableDeviceArgs;
pub const ClientAddressableMemoriesArgs = client.AddressableMemoriesArgs;
pub const ClientCompileArgs = client.CompileArgs;
pub const ClientDefaultDeviceAssignmentArgs = client.DefaultDeviceAssignmentArgs;
pub const ClientBufferFromHostBufferArgs = client.BufferFromHostBufferArgs;
pub const ClientTopologyDescriptionArgs = client.TopologyDescriptionArgs;
pub const ClientCreateViewOfDeviceBufferArgs = client.CreateViewOfDeviceBufferArgs;
pub const ClientDmaMapArgs = client.DmaMapArgs;
pub const ClientDmaUnmapArgs = client.DmaUnmapArgs;
pub const ClientLoadArgs = client.LoadArgs;
pub const ClientCreateBuffersForAsyncHostToDeviceArgs = client.CreateBuffersForAsyncHostToDeviceArgs;
pub const DeviceDescriptionIdArgs = device.DescriptionIdArgs;
pub const DeviceDescriptionProcessIndexArgs = device.DescriptionProcessIndexArgs;
pub const DeviceDescriptionAttributesArgs = device.DescriptionAttributesArgs;
pub const DeviceDescriptionKindArgs = device.DescriptionKindArgs;
pub const DeviceDescriptionDebugStringArgs = device.DescriptionDebugStringArgs;
pub const DeviceDescriptionToStringArgs = device.DescriptionToStringArgs;
pub const DeviceGetDescriptionArgs = device.GetDescriptionArgs;
pub const DeviceIsAddressableArgs = device.IsAddressableArgs;
pub const DeviceLocalHardwareIdArgs = device.LocalHardwareIdArgs;
pub const DeviceAddressableMemoriesArgs = device.AddressableMemoriesArgs;
pub const DeviceDefaultMemoryArgs = device.DefaultMemoryArgs;
pub const MemoryIdArgs = device.MemoryIdArgs;
pub const MemoryKindArgs = device.MemoryKindArgs;
pub const MemoryDebugStringArgs = device.MemoryDebugStringArgs;
pub const MemoryToStringArgs = device.MemoryToStringArgs;
pub const MemoryAddressableByDevicesArgs = device.MemoryAddressableByDevicesArgs;
pub const ExecutableDestroyArgs = exec.DestroyArgs;
pub const ExecutableNameArgs = exec.NameArgs;
pub const ExecutableNumReplicasArgs = exec.NumReplicasArgs;
pub const ExecutableNumPartitionsArgs = exec.NumPartitionsArgs;
pub const ExecutableNumOutputsArgs = exec.NumOutputsArgs;
pub const ExecutableSizeOfGeneratedCodeInBytesArgs = exec.SizeOfGeneratedCodeInBytesArgs;
pub const ExecutableSerializeArgs = exec.SerializeArgs;
pub const ExecutableDeserializeAndLoadArgs = exec.DeserializeAndLoadArgs;
pub const ExecutableFingerprintArgs = exec.FingerprintArgs;
pub const ExecutableGetCostAnalysisArgs = exec.GetCostAnalysisArgs;
pub const ExecutableOutputMemoryKindsArgs = exec.OutputMemoryKindsArgs;
pub const ExecutableGetCompiledMemoryStatsArgs = exec.GetCompiledMemoryStatsArgs;
pub const LoadedExecutableDestroyArgs = exec.LoadedDestroyArgs;
pub const LoadedExecutableGetExecutableArgs = exec.LoadedGetExecutableArgs;
pub const LoadedExecutableAddressableDevicesArgs = exec.LoadedAddressableDevicesArgs;
pub const LoadedExecutableDeleteArgs = exec.LoadedDeleteArgs;
pub const LoadedExecutableIsDeletedArgs = exec.LoadedIsDeletedArgs;
pub const LoadedExecutableExecuteArgs = exec.LoadedExecuteArgs;
pub const LoadedExecutableFingerprintArgs = exec.LoadedFingerprintArgs;
pub const LoadedExecutableGetDeviceAssignmentArgs = exec.LoadedGetDeviceAssignmentArgs;
pub const LoadOptions = exec.LoadOptions;
pub const BufferDestroyArgs = buffer.DestroyArgs;
pub const BufferElementTypeArgs = buffer.ElementTypeArgs;
pub const BufferDimensionsArgs = buffer.DimensionsArgs;
pub const BufferOnDeviceSizeInBytesArgs = buffer.OnDeviceSizeInBytesArgs;
pub const BufferDeviceArgs = buffer.DeviceArgs;
pub const BufferMemoryArgs = buffer.MemoryArgs;
pub const BufferDeleteArgs = buffer.DeleteArgs;
pub const BufferIsDeletedArgs = buffer.IsDeletedArgs;
pub const BufferCopyToDeviceArgs = buffer.CopyToDeviceArgs;
pub const BufferToHostBufferArgs = buffer.ToHostBufferArgs;
pub const BufferIsOnCpuArgs = buffer.IsOnCpuArgs;
pub const BufferReadyEventArgs = buffer.ReadyEventArgs;
pub const BufferUnsafePointerArgs = buffer.UnsafePointerArgs;
pub const BufferOpaqueDeviceMemoryDataPointerArgs = buffer.OpaqueDeviceMemoryDataPointerArgs;
pub const BufferGetMemoryLayoutArgs = buffer.GetMemoryLayoutArgs;
pub const BufferCopyRawToHostArgs = buffer.CopyRawToHostArgs;
pub const CompileArgs = exec.CompileArgs;
pub const ExecuteContextCreateArgs = exec.ExecuteContextCreateArgs;
pub const ExecuteContextDestroyArgs = exec.ExecuteContextDestroyArgs;
pub const DeviceMemoryStatsArgs = device.MemoryStatsArgs;
pub const DevicePoisonExecutionArgs = device.PoisonExecutionArgs;
pub const DeviceCreateAsyncTrackingEventArgs = device.CreateAsyncTrackingEventArgs;
pub const AsyncTrackingEventDestroyArgs = device.AsyncTrackingEventDestroyArgs;
pub const AsyncTrackingEventOnBlockingStartArgs = device.AsyncTrackingEventOnBlockingStartArgs;
pub const AsyncTrackingEventOnBlockingReadyArgs = device.AsyncTrackingEventOnBlockingReadyArgs;
pub const DeviceGetAttributesArgs = device.GetAttributesArgs;
pub const DeviceClearMemoryStatsArgs = device.ClearMemoryStatsArgs;
pub const CopyToDeviceStreamAddChunkArgs = stream.AddChunkArgs;
pub const CopyToDeviceStreamTotalBytesArgs = stream.TotalBytesArgs;
pub const CopyToDeviceStreamGranuleSizeArgs = stream.GranuleSizeArgs;
pub const CopyToDeviceStreamCurrentBytesArgs = stream.CurrentBytesArgs;
pub const CopyToDeviceStreamDestroyArgs = stream.DestroyArgs;
pub const TopologyDescriptionCreateArgs = topo.CreateArgs;
pub const TopologyDescriptionDestroyArgs = topo.DestroyArgs;
pub const TopologyDescriptionPlatformNameArgs = topo.PlatformNameArgs;
pub const TopologyDescriptionPlatformVersionArgs = topo.PlatformVersionArgs;
pub const TopologyDescriptionGetDeviceDescriptionsArgs = topo.GetDeviceDescriptionsArgs;
pub const TopologyDescriptionSerializeArgs = topo.SerializeArgs;
pub const TopologyDescriptionDeserializeArgs = topo.DeserializeArgs;
pub const TopologyDescriptionAttributesArgs = topo.AttributesArgs;
pub const TopologyDescriptionFingerprintArgs = topo.FingerprintArgs;
pub const TopologyDescriptionMakeCanonicalShapeForMemorySpaceArgs = topo.MakeCanonicalShapeForMemorySpaceArgs;
pub const TopologyDescriptionGetMemorySpaceKindIdsArgs = topo.GetMemorySpaceKindIdsArgs;
pub const ExecutableOutputElementTypesArgs = exec.OutputElementTypesArgs;
pub const ExecutableOutputDimensionsArgs = exec.OutputDimensionsArgs;
pub const ExecutableGetCompileOptionsArgs = exec.GetCompileOptionsArgs;
pub const ExecutableParameterMemoryKindsArgs = exec.ParameterMemoryKindsArgs;
pub const LoadedExecutableAddressableDeviceLogicalIdsArgs = exec.AddressableDeviceLogicalIdsArgs;
pub const BufferCopyRawToHostFutureArgs = buffer.CopyRawToHostFutureArgs;
pub const BufferDonateWithControlDependencyArgs = buffer.DonateWithControlDependencyArgs;
pub const BufferBitcastArgs = buffer.BitcastArgs;
pub const ErrorForEachPayloadArgs = errors.ForEachPayloadArgs;
pub const ClientUpdateGlobalProcessInfoArgs = client.UpdateGlobalProcessInfoArgs;
pub const ClientCreateAliasBufferArgs = client.CreateAliasBufferArgs;
pub const ClientFulfillAliasBufferArgs = client.FulfillAliasBufferArgs;
pub const ClientCreateErrorBufferArgs = client.CreateErrorBufferArgs;
pub const ClientCreateUninitializedBufferArgs = client.CreateUninitializedBufferArgs;
pub const AsyncHostToDeviceTransferManagerDestroyArgs = transfer.DestroyArgs;
pub const AsyncHostToDeviceTransferManagerTransferDataArgs = transfer.TransferDataArgs;
pub const AsyncHostToDeviceTransferManagerRetrieveBufferArgs = transfer.RetrieveBufferArgs;
pub const AsyncHostToDeviceTransferManagerDeviceArgs = transfer.DeviceArgs;
pub const AsyncHostToDeviceTransferManagerBufferCountArgs = transfer.BufferCountArgs;
pub const AsyncHostToDeviceTransferManagerBufferSizeArgs = transfer.BufferSizeArgs;
pub const AsyncHostToDeviceTransferManagerSetBufferErrorArgs = transfer.SetBufferErrorArgs;
pub const AsyncHostToDeviceTransferManagerAddMetadataArgs = transfer.AddMetadataArgs;
pub const AsyncHostToDeviceTransferManagerTransferLiteralArgs = transfer.TransferLiteralArgs;

pub const Api = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    pjrt_api_version: ApiVersion,
    error_destroy: *const fn (*ErrorDestroyArgs) callconv(.c) ?*Error,
    error_message: *const fn (*ErrorMessageArgs) callconv(.c) ?*Error,
    error_get_code: *const fn (*ErrorGetCodeArgs) callconv(.c) ?*Error,
    plugin_initialize: *const fn (*PluginInitializeArgs) callconv(.c) ?*Error,
    plugin_attributes: *const fn (*PluginAttributesArgs) callconv(.c) ?*Error,
    event_destroy: *const fn (*EventDestroyArgs) callconv(.c) ?*Error,
    event_is_ready: *const fn (*EventIsReadyArgs) callconv(.c) ?*Error,
    event_error: *const fn (*EventErrorArgs) callconv(.c) ?*Error,
    event_await: *const fn (*EventAwaitArgs) callconv(.c) ?*Error,
    event_on_ready: *const fn (*EventOnReadyArgs) callconv(.c) ?*Error,
    client_create: *const fn (*ClientCreateArgs) callconv(.c) ?*Error,
    client_destroy: *const fn (*ClientDestroyArgs) callconv(.c) ?*Error,
    client_platform_name: *const fn (*ClientPlatformNameArgs) callconv(.c) ?*Error,
    client_process_index: *const fn (*ClientProcessIndexArgs) callconv(.c) ?*Error,
    client_platform_version: *const fn (*ClientPlatformVersionArgs) callconv(.c) ?*Error,
    client_devices: *const fn (*ClientDevicesArgs) callconv(.c) ?*Error,
    client_addressable_devices: *const fn (*ClientAddressableDevicesArgs) callconv(.c) ?*Error,
    client_lookup_device: *const fn (*ClientLookupDeviceArgs) callconv(.c) ?*Error,
    client_lookup_addressable_device: *const fn (*ClientLookupAddressableDeviceArgs) callconv(.c) ?*Error,
    client_addressable_memories: *const fn (*ClientAddressableMemoriesArgs) callconv(.c) ?*Error,
    client_compile: *const fn (*ClientCompileArgs) callconv(.c) ?*Error,
    client_default_device_assignment: *const fn (*ClientDefaultDeviceAssignmentArgs) callconv(.c) ?*Error,
    client_buffer_from_host_buffer: *const fn (*ClientBufferFromHostBufferArgs) callconv(.c) ?*Error,
    device_description_id: *const fn (*DeviceDescriptionIdArgs) callconv(.c) ?*Error,
    device_description_process_index: *const fn (*DeviceDescriptionProcessIndexArgs) callconv(.c) ?*Error,
    device_description_attributes: *const fn (*DeviceDescriptionAttributesArgs) callconv(.c) ?*Error,
    device_description_kind: *const fn (*DeviceDescriptionKindArgs) callconv(.c) ?*Error,
    device_description_debug_string: *const fn (*DeviceDescriptionDebugStringArgs) callconv(.c) ?*Error,
    device_description_to_string: *const fn (*DeviceDescriptionToStringArgs) callconv(.c) ?*Error,
    device_get_description: *const fn (*DeviceGetDescriptionArgs) callconv(.c) ?*Error,
    device_is_addressable: *const fn (*DeviceIsAddressableArgs) callconv(.c) ?*Error,
    device_local_hardware_id: *const fn (*DeviceLocalHardwareIdArgs) callconv(.c) ?*Error,
    device_addressable_memories: *const fn (*DeviceAddressableMemoriesArgs) callconv(.c) ?*Error,
    device_default_memory: *const fn (*DeviceDefaultMemoryArgs) callconv(.c) ?*Error,
    device_memory_stats: *const fn (*DeviceMemoryStatsArgs) callconv(.c) ?*Error,
    memory_id: *const fn (*MemoryIdArgs) callconv(.c) ?*Error,
    memory_kind: *const fn (*MemoryKindArgs) callconv(.c) ?*Error,
    memory_debug_string: *const fn (*MemoryDebugStringArgs) callconv(.c) ?*Error,
    memory_to_string: *const fn (*MemoryToStringArgs) callconv(.c) ?*Error,
    memory_addressable_by_devices: *const fn (*MemoryAddressableByDevicesArgs) callconv(.c) ?*Error,
    executable_destroy: *const fn (*ExecutableDestroyArgs) callconv(.c) ?*Error,
    executable_name: *const fn (*ExecutableNameArgs) callconv(.c) ?*Error,
    executable_num_replicas: *const fn (*ExecutableNumReplicasArgs) callconv(.c) ?*Error,
    executable_num_partitions: *const fn (*ExecutableNumPartitionsArgs) callconv(.c) ?*Error,
    executable_num_outputs: *const fn (*ExecutableNumOutputsArgs) callconv(.c) ?*Error,
    executable_size_of_generated_code_in_bytes: *const fn (*ExecutableSizeOfGeneratedCodeInBytesArgs) callconv(.c) ?*Error,
    executable_get_cost_analysis: *const fn (*ExecutableGetCostAnalysisArgs) callconv(.c) ?*Error,
    executable_output_memory_kinds: *const fn (*ExecutableOutputMemoryKindsArgs) callconv(.c) ?*Error,
    executable_optimized_program: *const fn (*ExecutableSerializeArgs) callconv(.c) ?*Error,
    executable_serialize: *const fn (*ExecutableSerializeArgs) callconv(.c) ?*Error,
    loaded_executable_destroy: *const fn (*LoadedExecutableDestroyArgs) callconv(.c) ?*Error,
    loaded_executable_get_executable: *const fn (*LoadedExecutableGetExecutableArgs) callconv(.c) ?*Error,
    loaded_executable_addressable_devices: *const fn (*LoadedExecutableAddressableDevicesArgs) callconv(.c) ?*Error,
    loaded_executable_delete: *const fn (*LoadedExecutableDeleteArgs) callconv(.c) ?*Error,
    loaded_executable_is_deleted: *const fn (*LoadedExecutableIsDeletedArgs) callconv(.c) ?*Error,
    loaded_executable_execute: *const fn (*LoadedExecutableExecuteArgs) callconv(.c) ?*Error,
    executable_deserialize_and_load: *const fn (*ExecutableDeserializeAndLoadArgs) callconv(.c) ?*Error,
    loaded_executable_fingerprint: *const fn (*LoadedExecutableFingerprintArgs) callconv(.c) ?*Error,
    buffer_destroy: *const fn (*BufferDestroyArgs) callconv(.c) ?*Error,
    buffer_element_type: *const fn (*BufferElementTypeArgs) callconv(.c) ?*Error,
    buffer_dimensions: *const fn (*BufferDimensionsArgs) callconv(.c) ?*Error,
    buffer_unpadded_dimensions: *const fn (*BufferDimensionsArgs) callconv(.c) ?*Error,
    buffer_dynamic_dimension_indices: *const fn (*BufferDimensionsArgs) callconv(.c) ?*Error,
    buffer_get_memory_layout: *const fn (*BufferGetMemoryLayoutArgs) callconv(.c) ?*Error,
    buffer_on_device_size_in_bytes: *const fn (*BufferOnDeviceSizeInBytesArgs) callconv(.c) ?*Error,
    buffer_device: *const fn (*BufferDeviceArgs) callconv(.c) ?*Error,
    buffer_memory: *const fn (*BufferMemoryArgs) callconv(.c) ?*Error,
    buffer_delete: *const fn (*BufferDeleteArgs) callconv(.c) ?*Error,
    buffer_is_deleted: *const fn (*BufferIsDeletedArgs) callconv(.c) ?*Error,
    buffer_copy_to_device: *const fn (*BufferCopyToDeviceArgs) callconv(.c) ?*Error,
    buffer_to_host_buffer: *const fn (*BufferToHostBufferArgs) callconv(.c) ?*Error,
    buffer_is_on_cpu: *const fn (*BufferIsOnCpuArgs) callconv(.c) ?*Error,
    buffer_ready_event: *const fn (*BufferReadyEventArgs) callconv(.c) ?*Error,
    buffer_unsafe_pointer: *const fn (*BufferUnsafePointerArgs) callconv(.c) ?*Error,
    buffer_increase_external_reference_count: *const fn (*BufferDeleteArgs) callconv(.c) ?*Error,
    buffer_decrease_external_reference_count: *const fn (*BufferDeleteArgs) callconv(.c) ?*Error,
    buffer_opaque_device_memory_data_pointer: *const fn (*BufferOpaqueDeviceMemoryDataPointerArgs) callconv(.c) ?*Error,
    copy_to_device_stream_destroy: *const fn (*CopyToDeviceStreamDestroyArgs) callconv(.c) ?*Error,
    copy_to_device_stream_add_chunk: *const fn (*CopyToDeviceStreamAddChunkArgs) callconv(.c) ?*Error,
    copy_to_device_stream_total_bytes: *const fn (*CopyToDeviceStreamTotalBytesArgs) callconv(.c) ?*Error,
    copy_to_device_stream_granule_size: *const fn (*CopyToDeviceStreamGranuleSizeArgs) callconv(.c) ?*Error,
    copy_to_device_stream_current_bytes: *const fn (*CopyToDeviceStreamCurrentBytesArgs) callconv(.c) ?*Error,
    topology_description_create: *const fn (*TopologyDescriptionCreateArgs) callconv(.c) ?*Error,
    topology_description_destroy: *const fn (*TopologyDescriptionDestroyArgs) callconv(.c) ?*Error,
    topology_description_platform_name: *const fn (*TopologyDescriptionPlatformNameArgs) callconv(.c) ?*Error,
    topology_description_platform_version: *const fn (*TopologyDescriptionPlatformVersionArgs) callconv(.c) ?*Error,
    topology_description_get_device_descriptions: *const fn (*TopologyDescriptionGetDeviceDescriptionsArgs) callconv(.c) ?*Error,
    topology_description_serialize: *const fn (*TopologyDescriptionSerializeArgs) callconv(.c) ?*Error,
    topology_description_attributes: *const fn (*TopologyDescriptionAttributesArgs) callconv(.c) ?*Error,
    compile: *const fn (*CompileArgs) callconv(.c) ?*Error,
    executable_output_element_types: *const fn (*ExecutableOutputElementTypesArgs) callconv(.c) ?*Error,
    executable_output_dimensions: *const fn (*ExecutableOutputDimensionsArgs) callconv(.c) ?*Error,
    buffer_copy_to_memory: *const fn (*BufferCopyToDeviceArgs) callconv(.c) ?*Error,
    client_create_view_of_device_buffer: *const fn (*ClientCreateViewOfDeviceBufferArgs) callconv(.c) ?*Error,
    executable_fingerprint: *const fn (*ExecutableFingerprintArgs) callconv(.c) ?*Error,
    client_topology_description: *const fn (*ClientTopologyDescriptionArgs) callconv(.c) ?*Error,
    executable_get_compiled_memory_stats: *const fn (*ExecutableGetCompiledMemoryStatsArgs) callconv(.c) ?*Error,
    memory_kind_id: *const fn (*MemoryKindArgs) callconv(.c) ?*Error,
    execute_context_create: *const fn (*ExecuteContextCreateArgs) callconv(.c) ?*Error,
    execute_context_destroy: *const fn (*ExecuteContextDestroyArgs) callconv(.c) ?*Error,
    buffer_copy_raw_to_host: *const fn (*BufferCopyRawToHostArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_destroy: *const fn (*AsyncHostToDeviceTransferManagerDestroyArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_transfer_data: *const fn (*AsyncHostToDeviceTransferManagerTransferDataArgs) callconv(.c) ?*Error,
    client_create_buffers_for_async_host_to_device: *const fn (*ClientCreateBuffersForAsyncHostToDeviceArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_retrieve_buffer: *const fn (*AsyncHostToDeviceTransferManagerRetrieveBufferArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_device: *const fn (*AsyncHostToDeviceTransferManagerDeviceArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_buffer_count: *const fn (*AsyncHostToDeviceTransferManagerBufferCountArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_buffer_size: *const fn (*AsyncHostToDeviceTransferManagerBufferSizeArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_set_buffer_error: *const fn (*AsyncHostToDeviceTransferManagerSetBufferErrorArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_add_metadata: *const fn (*AsyncHostToDeviceTransferManagerAddMetadataArgs) callconv(.c) ?*Error,
    client_dma_map: *const fn (*ClientDmaMapArgs) callconv(.c) ?*Error,
    client_dma_unmap: *const fn (*ClientDmaUnmapArgs) callconv(.c) ?*Error,
    client_create_uninitialized_buffer: *const fn (*ClientCreateUninitializedBufferArgs) callconv(.c) ?*Error,
    client_update_global_process_info: *const fn (*ClientUpdateGlobalProcessInfoArgs) callconv(.c) ?*Error,
    topology_description_deserialize: *const fn (*TopologyDescriptionDeserializeArgs) callconv(.c) ?*Error,
    client_create_alias_buffer: *const fn (*ClientCreateAliasBufferArgs) callconv(.c) ?*Error,
    client_fulfill_alias_buffer: *const fn (*ClientFulfillAliasBufferArgs) callconv(.c) ?*Error,
    loaded_executable_get_device_assignment: *const fn (*LoadedExecutableGetDeviceAssignmentArgs) callconv(.c) ?*Error,
    client_create_error_buffer: *const fn (*ClientCreateErrorBufferArgs) callconv(.c) ?*Error,
    async_host_to_device_transfer_manager_transfer_literal: *const fn (*AsyncHostToDeviceTransferManagerTransferLiteralArgs) callconv(.c) ?*Error,
    buffer_copy_raw_to_host_future: *const fn (*BufferCopyRawToHostFutureArgs) callconv(.c) ?*Error,
    device_poison_execution: *const fn (*DevicePoisonExecutionArgs) callconv(.c) ?*Error,
    device_create_async_tracking_event: *const fn (*DeviceCreateAsyncTrackingEventArgs) callconv(.c) ?*Error,
    async_tracking_event_destroy: *const fn (*AsyncTrackingEventDestroyArgs) callconv(.c) ?*Error,
    executable_get_compile_options: *const fn (*ExecutableGetCompileOptionsArgs) callconv(.c) ?*Error,
    buffer_donate_with_control_dependency: *const fn (*BufferDonateWithControlDependencyArgs) callconv(.c) ?*Error,
    event_create: *const fn (*EventCreateArgs) callconv(.c) ?*Error,
    event_set: *const fn (*EventArgs) callconv(.c) ?*Error,
    device_get_attributes: *const fn (*DeviceGetAttributesArgs) callconv(.c) ?*Error,
    client_load: *const fn (*ClientLoadArgs) callconv(.c) ?*Error,
    loaded_executable_addressable_device_logical_ids: *const fn (*LoadedExecutableAddressableDeviceLogicalIdsArgs) callconv(.c) ?*Error,
    buffer_bitcast: *const fn (*BufferBitcastArgs) callconv(.c) ?*Error,
    error_for_each_payload: *const fn (*ErrorForEachPayloadArgs) callconv(.c) ?*Error,
    topology_description_fingerprint: *const fn (*TopologyDescriptionFingerprintArgs) callconv(.c) ?*Error,
    executable_parameter_memory_kinds: *const fn (*ExecutableParameterMemoryKindsArgs) callconv(.c) ?*Error,
    device_clear_memory_stats: *const fn (*DeviceClearMemoryStatsArgs) callconv(.c) ?*Error,
    topology_description_make_canonical_shape_for_memory_space: *const fn (*TopologyDescriptionMakeCanonicalShapeForMemorySpaceArgs) callconv(.c) ?*Error,
    topology_description_get_memory_space_kind_ids: *const fn (*TopologyDescriptionGetMemorySpaceKindIdsArgs) callconv(.c) ?*Error,
};

pub fn getPjrtApi(plugin: *std.DynLib) ?*const Api {
    const func = plugin.lookup(*const fn () callconv(.c) *const Api, "GetPjrtApi") orelse return null;
    return func();
}
