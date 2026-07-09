package pjrt

Api :: struct {
	struct_size:                                                uint,
	extension_start:                                            ^Extension_Base,
	pjrt_api_version:                                           Api_Version,
	error_destroy:                                              proc "c" (
		args: ^Error_Destroy_Args,
	),
	error_message:                                              proc "c" (
		args: ^Error_Message_Args,
	),
	error_get_code:                                             proc "c" (
		args: ^Error_Get_Code_Args,
	) -> Error,
	plugin_initialize:                                          proc "c" (
		args: ^Plugin_Initialize_Args,
	) -> Error,
	plugin_attributes:                                          proc "c" (
		args: ^Plugin_Attributes_Args,
	) -> Error,
	event_destroy:                                              proc "c" (
		args: ^Event_Destroy_Args,
	) -> Error,
	event_is_ready:                                             proc "c" (
		args: ^Event_Is_Ready_Args,
	) -> Error,
	event_error:                                                proc "c" (
		args: ^Event_Error_Args,
	) -> Error,
	event_await:                                                proc "c" (
		args: ^Event_Await_Args,
	) -> Error,
	event_on_ready:                                             proc "c" (
		args: ^Event_On_Ready_Args,
	) -> Error,
	client_create:                                              proc "c" (
		args: ^Client_Create_Args,
	) -> Error,
	client_destroy:                                             proc "c" (
		args: ^Client_Destroy_Args,
	) -> Error,
	client_platform_name:                                       proc "c" (
		args: ^Client_Platform_Name_Args,
	) -> Error,
	client_process_index:                                       proc "c" (
		args: ^Client_Process_Index_Args,
	) -> Error,
	client_platform_version:                                    proc "c" (
		args: ^Client_Platform_Version_Args,
	) -> Error,
	client_devices:                                             proc "c" (
		args: ^Client_Devices_Args,
	) -> Error,
	client_addressable_devices:                                 proc "c" (
		args: ^Client_Addressable_Devices_Args,
	) -> Error,
	client_lookup_device:                                       proc "c" (
		args: ^Client_Lookup_Device_Args,
	) -> Error,
	client_lookup_addressable_device:                           proc "c" (
		args: ^Client_Lookup_Addressable_Device_Args,
	) -> Error,
	client_addressable_memories:                                proc "c" (
		args: ^Client_Addressable_Memories_Args,
	) -> Error,
	client_compile:                                             proc "c" (
		args: ^Client_Compile_Args,
	) -> Error,
	client_default_device_assignment:                           proc "c" (
		args: ^Client_Default_Device_Assignment_Args,
	) -> Error,
	client_buffer_from_host_buffer:                             proc "c" (
		args: ^Client_Buffer_From_Host_Buffer_Args,
	) -> Error,
	device_description_id:                                      proc "c" (
		args: ^Device_Description_Id_Args,
	) -> Error,
	device_description_process_index:                           proc "c" (
		args: ^Device_Description_Process_Index_Args,
	) -> Error,
	device_description_attributes:                              proc "c" (
		args: ^Device_Description_Attributes_Args,
	) -> Error,
	device_description_kind:                                    proc "c" (
		args: ^Device_Description_Kind_Args,
	) -> Error,
	device_description_debug_string:                            proc "c" (
		args: ^Device_Description_Debug_String_Args,
	) -> Error,
	device_description_to_string:                               proc "c" (
		args: ^Device_Description_To_String_Args,
	) -> Error,
	device_get_description:                                     proc "c" (
		args: ^Device_Get_Description_Args,
	) -> Error,
	device_is_addressable:                                      proc "c" (
		args: ^Device_Is_Addressable_Args,
	) -> Error,
	device_local_hardware_id:                                   proc "c" (
		args: ^Device_Local_Hardware_Id_Args,
	) -> Error,
	device_addressable_memories:                                proc "c" (
		args: ^Device_Addressable_Memories_Args,
	) -> Error,
	device_default_memory:                                      proc "c" (
		args: ^Device_Default_Memory_Args,
	) -> Error,
	device_memory_stats:                                        proc "c" (
		args: ^Device_Memory_Stats_Args,
	) -> Error,
	memory_id:                                                  proc "c" (
		args: ^Memory_Id_Args,
	) -> Error,
	memory_kind:                                                proc "c" (
		args: ^Memory_Kind_Args,
	) -> Error,
	memory_debug_string:                                        proc "c" (
		args: ^Memory_Debug_String_Args,
	) -> Error,
	memory_to_string:                                           proc "c" (
		args: ^Memory_To_String_Args,
	) -> Error,
	memory_addressable_by_devices:                              proc "c" (
		args: ^Memory_Addressable_By_Devices_Args,
	) -> Error,
	executable_destroy:                                         proc "c" (
		args: ^Executable_Destroy_Args,
	) -> Error,
	executable_name:                                            proc "c" (
		args: ^Executable_Name_Args,
	) -> Error,
	executable_num_replicas:                                    proc "c" (
		args: ^Executable_Num_Replicas_Args,
	) -> Error,
	executable_num_partitions:                                  proc "c" (
		args: ^Executable_Num_Partitions_Args,
	) -> Error,
	executable_num_outputs:                                     proc "c" (
		args: ^Executable_Num_Outputs_Args,
	) -> Error,
	executable_size_of_generated_code_in_bytes:                 proc "c" (
		args: ^Executable_Size_Of_Generated_Code_In_Bytes_Args,
	) -> Error,
	executable_get_cost_analysis:                               proc "c" (
		args: ^Executable_Get_Cost_Analysis_Args,
	) -> Error,
	executable_output_memory_kinds:                             proc "c" (
		args: ^Executable_Output_Memory_Kinds_Args,
	) -> Error,
	executable_optimized_program:                               proc "c" (
		args: ^Executable_Optimized_Program_Args,
	) -> Error,
	executable_serialize:                                       proc "c" (
		args: ^Executable_Serialize_Args,
	) -> Error,
	loaded_executable_destroy:                                  proc "c" (
		args: ^Loaded_Executable_Destroy_Args,
	) -> Error,
	loaded_executable_get_executable:                           proc "c" (
		args: ^Loaded_Executable_Get_Executable_Args,
	) -> Error,
	loaded_executable_addressable_devices:                      proc "c" (
		args: ^Loaded_Executable_Addressable_Devices_Args,
	) -> Error,
	loaded_executable_delete:                                   proc "c" (
		args: ^Loaded_Executable_Delete_Args,
	) -> Error,
	loaded_executable_is_deleted:                               proc "c" (
		args: ^Loaded_Executable_Is_Deleted_Args,
	) -> Error,
	loaded_executable_execute:                                  proc "c" (
		args: ^Loaded_Executable_Execute_Args,
	) -> Error,
	executable_deserialize_and_load:                            proc "c" (
		args: ^Executable_Deserialize_And_Load_Args,
	) -> Error,
	loaded_executable_fingerprint:                              proc "c" (
		args: ^Loaded_Executable_Fingerprint_Args,
	) -> Error,
	buffer_destroy:                                             proc "c" (
		args: ^Buffer_Destroy_Args,
	) -> Error,
	buffer_element_type:                                        proc "c" (
		args: ^Buffer_Element_Type_Args,
	) -> Error,
	buffer_dimensions:                                          proc "c" (
		args: ^Buffer_Dimensions_Args,
	) -> Error,
	buffer_unpadded_dimensions:                                 proc "c" (
		args: ^Buffer_Unpadded_Dimensions_Args,
	) -> Error,
	buffer_dynamic_dimension_indices:                           proc "c" (
		args: ^Buffer_Dynamic_Dimension_Indices_Args,
	) -> Error,
	buffer_get_memory_layout:                                   proc "c" (
		args: ^Buffer_Get_Memory_Layout_Args,
	) -> Error,
	buffer_on_device_size_in_bytes:                             proc "c" (
		args: ^Buffer_On_Device_Size_In_Bytes_Args,
	) -> Error,
	buffer_device:                                              proc "c" (
		args: ^Buffer_Device_Args,
	) -> Error,
	buffer_memory:                                              proc "c" (
		args: ^Buffer_Memory_Args,
	) -> Error,
	buffer_delete:                                              proc "c" (
		args: ^Buffer_Delete_Args,
	) -> Error,
	buffer_is_deleted:                                          proc "c" (
		args: ^Buffer_Is_Deleted_Args,
	) -> Error,
	buffer_copy_to_device:                                      proc "c" (
		args: ^Buffer_Copy_To_Device_Args,
	) -> Error,
	buffer_to_host_buffer:                                      proc "c" (
		args: ^Buffer_To_Host_Buffer_Args,
	) -> Error,
	buffer_is_on_cpu:                                           proc "c" (
		args: ^Buffer_Is_On_Cpu_Args,
	) -> Error,
	buffer_ready_event:                                         proc "c" (
		args: ^Buffer_Ready_Event_Args,
	) -> Error,
	buffer_unsafe_pointer:                                      proc "c" (
		args: ^Buffer_Unsafe_Pointer_Args,
	) -> Error,
	buffer_increase_external_reference_count:                   proc "c" (
		args: ^Buffer_Increase_External_Reference_Count_Args,
	) -> Error,
	buffer_decrease_external_reference_count:                   proc "c" (
		args: ^Buffer_Decrease_External_Reference_Count_Args,
	) -> Error,
	buffer_opaque_device_memory_data_pointer:                   proc "c" (
		args: ^Buffer_Opaque_Device_Memory_Data_Pointer_Args,
	) -> Error,
	copy_to_device_stream_destroy:                              proc "c" (
		args: ^Copy_To_Device_Stream_Destroy_Args,
	) -> Error,
	copy_to_device_stream_add_chunk:                            proc "c" (
		args: ^Copy_To_Device_Stream_Add_Chunk_Args,
	) -> Error,
	copy_to_device_stream_total_bytes:                          proc "c" (
		args: ^Copy_To_Device_Stream_Total_Bytes_Args,
	) -> Error,
	copy_to_device_stream_granule_size:                         proc "c" (
		args: ^Copy_To_Device_Stream_Granule_Size_Args,
	) -> Error,
	copy_to_device_stream_current_bytes:                        proc "c" (
		args: ^Copy_To_Device_Stream_Current_Bytes_Args,
	) -> Error,
	topology_description_create:                                proc "c" (
		args: ^Topology_Description_Create_Args,
	) -> Error,
	topology_description_destroy:                               proc "c" (
		args: ^Topology_Description_Destroy_Args,
	) -> Error,
	topology_description_platform_name:                         proc "c" (
		args: ^Topology_Description_Platform_Name_Args,
	) -> Error,
	topology_description_platform_version:                      proc "c" (
		args: ^Topology_Description_Platform_Version_Args,
	) -> Error,
	topology_description_get_device_descriptions:               proc "c" (
		args: ^Topology_Description_Get_Device_Descriptions_Args,
	) -> Error,
	topology_description_serialize:                             proc "c" (
		args: ^Topology_Description_Serialize_Args,
	) -> Error,
	topology_description_attributes:                            proc "c" (
		args: ^Topology_Description_Attributes_Args,
	) -> Error,
	compile:                                                    proc "c" (
		args: ^Compile_Args,
	) -> Error,
	executable_output_element_types:                            proc "c" (
		args: ^Executable_Output_Element_Types_Args,
	) -> Error,
	executable_output_dimensions:                               proc "c" (
		args: ^Executable_Output_Dimensions_Args,
	) -> Error,
	buffer_copy_to_memory:                                      proc "c" (
		args: ^Buffer_Copy_To_Memory_Args,
	) -> Error,
	client_create_view_of_device_buffer:                        proc "c" (
		args: ^Client_Create_View_Of_Device_Buffer_Args,
	) -> Error,
	executable_fingerprint:                                     proc "c" (
		args: ^Executable_Fingerprint_Args,
	) -> Error,
	client_topology_description:                                proc "c" (
		args: ^Client_Topology_Description_Args,
	) -> Error,
	executable_get_compiled_memory_stats:                       proc "c" (
		args: ^Executable_Get_Compiled_Memory_Stats_Args,
	) -> Error,
	memory_kind_id:                                             proc "c" (
		args: ^Memory_Kind_Id_Args,
	) -> Error,
	execute_context_create:                                     proc "c" (
		args: ^Execute_Context_Create_Args,
	) -> Error,
	execute_context_destroy:                                    proc "c" (
		args: ^Execute_Context_Destroy_Args,
	) -> Error,
	buffer_copy_raw_to_host:                                    proc "c" (
		args: ^Buffer_Copy_Raw_To_Host_Args,
	) -> Error,
	async_host_to_device_transfer_manager_destroy:              proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Destroy_Args,
	) -> Error,
	async_host_to_device_transfer_manager_transfer_data:        proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Transfer_Data_Args,
	) -> Error,
	client_create_buffers_for_async_host_to_device:             proc "c" (
		args: ^Client_Create_Buffers_For_Async_Host_To_Device_Args,
	) -> Error,
	async_host_to_device_transfer_manager_retrieve_buffer:      proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Retrieve_Buffer_Args,
	) -> Error,
	async_host_to_device_transfer_manager_device:               proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Device_Args,
	) -> Error,
	async_host_to_device_transfer_manager_buffer_count:         proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Buffer_Count_Args,
	) -> Error,
	async_host_to_device_transfer_manager_buffer_size:          proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Buffer_Size_Args,
	) -> Error,
	async_host_to_device_transfer_manager_set_buffer_error:     proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Set_Buffer_Error_Args,
	) -> Error,
	async_host_to_device_transfer_manager_add_metadata:         proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Add_Metadata_Args,
	) -> Error,
	client_dma_map:                                             proc "c" (
		args: ^Client_Dma_Map_Args,
	) -> Error,
	client_dma_unmap:                                           proc "c" (
		args: ^Client_Dma_Unmap_Args,
	) -> Error,
	client_create_uninitialized_buffer:                         proc "c" (
		args: ^Client_Create_Uninitialized_Buffer_Args,
	) -> Error,
	client_update_global_process_info:                          proc "c" (
		args: ^Client_Update_Global_Process_Info_Args,
	) -> Error,
	topology_description_deserialize:                           proc "c" (
		args: ^Topology_Description_Deserialize_Args,
	) -> Error,
	client_create_alias_buffer:                                 proc "c" (
		args: ^Client_Create_Alias_Buffer_Args,
	) -> Error,
	client_fulfill_alias_buffer:                                proc "c" (
		args: ^Client_Fulfill_Alias_Buffer_Args,
	) -> Error,
	loaded_executable_get_device_assignment:                    proc "c" (
		args: ^Loaded_Executable_Get_Device_Assignment_Args,
	) -> Error,
	client_create_error_buffer:                                 proc "c" (
		args: ^Client_Create_Error_Buffer_Args,
	) -> Error,
	async_host_to_device_transfer_manager_transfer_literal:     proc "c" (
		args: ^Async_Host_To_Device_Transfer_Manager_Transfer_Literal_Args,
	) -> Error,
	buffer_copy_raw_to_host_future:                             proc "c" (
		args: ^Buffer_Copy_Raw_To_Host_Future_Args,
	) -> Error,
	device_poison_execution:                                    proc "c" (
		args: ^Device_Poison_Execution_Args,
	) -> Error,
	device_create_async_tracking_event:                         proc "c" (
		args: ^Device_Create_Async_Tracking_Event_Args,
	) -> Error,
	async_tracking_event_destroy:                               proc "c" (
		args: ^Async_Tracking_Event_Destroy_Args,
	) -> Error,
	executable_get_compile_options:                             proc "c" (
		args: ^Executable_Get_Compile_Options_Args,
	) -> Error,
	buffer_donate_with_control_dependency:                      proc "c" (
		args: ^Buffer_Donate_With_Control_Dependency_Args,
	) -> Error,
	event_create:                                               proc "c" (
		args: ^Event_Create_Args,
	) -> Error,
	event_set:                                                  proc "c" (
		args: ^Event_Set_Args,
	) -> Error,
	device_get_attributes:                                      proc "c" (
		args: ^Device_Get_Attributes_Args,
	) -> Error,
	client_load:                                                proc "c" (
		args: ^Client_Load_Args,
	) -> Error,
	loaded_executable_addressable_device_logical_ids:           proc "c" (
		args: ^Loaded_Executable_Addressable_Device_Logical_Ids_Args,
	) -> Error,
	buffer_bitcast:                                             proc "c" (
		args: ^Buffer_Bitcast_Args,
	) -> Error,
	error_for_each_payload:                                     proc "c" (
		args: ^Error_For_Each_Payload_Args,
	) -> Error,
	topology_description_fingerprint:                           proc "c" (
		args: ^Topology_Description_Fingerprint_Args,
	) -> Error,
	executable_parameter_memory_kinds:                          proc "c" (
		args: ^Executable_Parameter_Memory_Kinds_Args,
	) -> Error,
	device_clear_memory_stats:                                  proc "c" (
		args: ^Device_Clear_Memory_Stats_Args,
	) -> Error,
	topology_description_make_canonical_shape_for_memory_space: proc "c" (
		args: ^Topology_Description_Make_Canonical_Shape_For_Memory_Space_Args,
	) -> Error,
	topology_description_get_memory_space_kind_ids:             proc "c" (
		args: ^Topology_Description_Get_Memory_Space_Kind_Ids_Args,
	) -> Error,
}

Load :: proc(plugin_path: string) -> (api: ^Api, ok: bool) {
	cstr := make([]u8, len(plugin_path) + 1)
	defer delete(cstr)
	copy(cstr, plugin_path)
	cstr[len(plugin_path)] = 0

	when ODIN_OS == .Windows {
		lib := LoadLibraryA(cstring(&cstr[0]))
		if lib == nil {
			return nil, false
		}
		get_api := cast(proc "c" () -> ^Api)GetProcAddress(lib, "GetPjrtApi")
		if get_api == nil {
			FreeLibrary(lib)
			return nil, false
		}
		return get_api(), true
	} else {
		lib := dlopen(cstring(&cstr[0]), 1) // RTLD_LAZY = 1
		if lib == nil {
			return nil, false
		}
		get_api := cast(proc "c" () -> ^Api)dlsym(lib, "GetPjrtApi")
		if get_api == nil {
			dlclose(lib)
			return nil, false
		}
		return get_api(), true
	}
}
