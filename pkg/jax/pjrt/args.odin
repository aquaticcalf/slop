package pjrt

import "core:c"

// Error Args
Error_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	error:           Error,
}

Error_Message_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	error:           Error,
	message:         cstring,
	message_size:    uint,
}

Error_Get_Code_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	error:           Error,
	code:            Error_Code,
}

Error_For_Each_Payload_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	error:           Error,
	visitor:         Error_Payload_Visitor,
	user_arg:        rawptr,
}

// Plugin Args
Plugin_Initialize_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
}

Plugin_Attributes_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	attributes:      ^Named_Value,
	num_attributes:  uint,
}

// Event Args
Event_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Event,
}

Event_Is_Ready_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Event,
	is_ready:        b32,
}

Event_Error_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Event,
}

Event_Await_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Event,
}

Event_On_Ready_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Event,
	callback:        Event_On_Ready_Callback,
	user_arg:        rawptr,
}

Event_Create_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Event,
}

Event_Set_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	event:              Event,
	error_code:         Error_Code,
	error_message:      cstring,
	error_message_size: uint,
}

// Client Args
Key_Value_Get_Callback_Args :: struct {
	struct_size:             uint,
	extension_start:         ^Extension_Base,
	key:                     cstring,
	key_size:                uint,
	timeout_in_ms:           c.int,
	callback_error:          ^Callback_Error,
	user_arg:                rawptr,
	value:                   cstring,
	value_size:              uint,
	value_deleter_callback:  Key_Value_Get_Callback_Value_Deleter,
}

Key_Value_Try_Get_Callback_Args :: struct {
	struct_size:             uint,
	extension_start:         ^Extension_Base,
	key:                     cstring,
	key_size:                uint,
	callback_error:          ^Callback_Error,
	user_arg:                rawptr,
	value:                   cstring,
	value_size:              uint,
	value_deleter_callback:  Key_Value_Try_Get_Callback_Value_Deleter,
}

Key_Value_Put_Callback_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	key:             cstring,
	key_size:        uint,
	value:           cstring,
	value_size:      uint,
	callback_error:  ^Callback_Error,
	user_arg:        rawptr,
}

Client_Create_Args :: struct {
	struct_size:             uint,
	extension_start:         ^Extension_Base,
	create_options:          ^Named_Value,
	num_options:             uint,
	kv_get_callback:         Key_Value_Get_Callback,
	kv_get_user_arg:         rawptr,
	kv_put_callback:         Key_Value_Put_Callback,
	kv_put_user_arg:         rawptr,
	client:                  Client,
	kv_try_get_callback:     Key_Value_Try_Get_Callback,
	kv_try_get_user_arg:     rawptr,
}

Client_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
}

Client_Platform_Name_Args :: struct {
	struct_size:       uint,
	extension_start:   ^Extension_Base,
	client:            Client,
	platform_name:     cstring,
	platform_name_size: uint,
}

Client_Process_Index_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
	process_index:   c.int,
}

Client_Platform_Version_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	client:               Client,
	platform_version:     cstring,
	platform_version_size: uint,
}

Client_Topology_Description_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
	topology:        Topology_Description,
}

Client_Devices_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
	devices:         [^]Device,
	num_devices:     uint,
}

Client_Addressable_Devices_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	client:                   Client,
	addressable_devices:      [^]Device,
	num_addressable_devices:  uint,
}

Client_Lookup_Device_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
	id:              c.int,
	device:          Device,
}

Client_Lookup_Addressable_Device_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	client:               Client,
	local_hardware_id:    c.int,
	addressable_device:   Device,
}

Client_Update_Global_Process_Info_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	client:             Client,
	process_infos:      ^Process_Info,
	num_process_infos:  uint,
}

Client_Addressable_Memories_Args :: struct {
	struct_size:                  uint,
	extension_start:              ^Extension_Base,
	client:                       Client,
	addressable_memories:         [^]Memory,
	num_addressable_memories:     uint,
}

Client_Compile_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	client:               Client,
	program:              ^Program,
	compile_options:      cstring,
	compile_options_size: uint,
	executable:           Loaded_Executable,
}

Client_Load_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	client:               Client,
	executable:           Executable,
	compile_options:      cstring,
	compile_options_size: uint,
	loaded_executable:    Loaded_Executable,
}

Client_Default_Device_Assignment_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	client:                   Client,
	num_replicas:             c.int,
	num_partitions:           c.int,
	default_assignment_size:  uint,
	default_assignment:       [^]c.int,
}

Client_Dma_Map_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
	data:            rawptr,
	size:            uint,
}

Client_Dma_Unmap_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	client:          Client,
	data:            rawptr,
}

Client_Buffer_From_Host_Buffer_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	client:                   Client,
	data:                     rawptr,
	type:                     Buffer_Type,
	dims:                     [^]i64,
	num_dims:                 uint,
	byte_strides:             [^]i64,
	num_byte_strides:         uint,
	host_buffer_semantics:    Host_Buffer_Semantics,
	device:                   Device,
	memory:                   Memory,
	device_layout:            ^Buffer_Memory_Layout,
	done_with_host_buffer:    Event,
	buffer:                   Buffer,
}

Client_Create_View_Of_Device_Buffer_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	client:                   Client,
	device_buffer_ptr:        rawptr,
	dims:                     [^]i64,
	num_dims:                 uint,
	element_type:             Buffer_Type,
	layout:                   ^Buffer_Memory_Layout,
	device:                   Device,
	on_delete_callback:       proc "c" (device_buffer_ptr: rawptr, user_arg: rawptr),
	on_delete_callback_arg:   rawptr,
	stream:                   uint,
	buffer:                   Buffer,
	memory:                   Memory,
}

Client_Create_Buffers_For_Async_Host_To_Device_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	client:               Client,
	shape_specs:          [^]Shape_Spec,
	num_shape_specs:      uint,
	device_layouts:       [^]Buffer_Memory_Layout,
	num_device_layouts:   uint,
	memory:               Memory,
	transfer_manager:     Async_Host_To_Device_Transfer_Manager,
}

Client_Create_Uninitialized_Buffer_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	client:             Client,
	dims:               [^]i64,
	num_dims:           uint,
	element_type:       Buffer_Type,
	layout:             ^Buffer_Memory_Layout,
	device:             Device,
	memory:             Memory,
	buffer:             Buffer,
}

Client_Create_Error_Buffer_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	client:             Client,
	error_code:         Error_Code,
	error_message:      cstring,
	error_message_size: uint,
	dims:               [^]i64,
	num_dims:           uint,
	element_type:       Buffer_Type,
	layout:             ^Buffer_Memory_Layout,
	memory:             Memory,
	buffer:             Buffer,
	payload:            ^Named_Value,
	num_payload:        uint,
}

Client_Create_Alias_Buffer_Args :: struct {
	struct_size:               uint,
	extension_start:           ^Extension_Base,
	client:                    Client,
	memory:                    Memory,
	dims:                      [^]i64,
	num_dims:                  uint,
	element_type:              Buffer_Type,
	layout:                    ^Buffer_Memory_Layout,
	alias_buffer:              Buffer,
	fulfill_alias_buffer_cb:   Fulfill_Alias_Buffer_Callback,
}

Client_Fulfill_Alias_Buffer_Args :: struct {
	struct_size:               uint,
	extension_start:           ^Extension_Base,
	client:                    Client,
	buffer:                    Buffer,
	status_code:               Error_Code,
	error_message:             cstring,
	error_message_size:        uint,
	fulfill_alias_buffer_cb:   Fulfill_Alias_Buffer_Callback,
}

// Device Description Args
Device_Description_Id_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device_description:   Device_Description,
	id:                   c.int,
}

Device_Description_Process_Index_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device_description:   Device_Description,
	process_index:        c.int,
}

Device_Description_Attributes_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device_description:   Device_Description,
	attributes:           ^Named_Value,
	num_attributes:       uint,
}

Device_Description_Kind_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device_description:   Device_Description,
	device_kind:          cstring,
	device_kind_size:     uint,
}

Device_Description_Debug_String_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device_description:   Device_Description,
	debug_string:         cstring,
	debug_string_size:    uint,
}

Device_Description_To_String_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device_description:   Device_Description,
	to_string:            cstring,
	to_string_size:       uint,
}

// Device Args
Device_Get_Description_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	device:               Device,
	device_description:   Device_Description,
}

Device_Is_Addressable_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	device:          Device,
	is_addressable:  b32,
}

Device_Local_Hardware_Id_Args :: struct {
	struct_size:       uint,
	extension_start:   ^Extension_Base,
	device:            Device,
	local_hardware_id: c.int,
}

Device_Addressable_Memories_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	device:          Device,
	memories:        [^]Memory,
	num_memories:    uint,
}

Device_Default_Memory_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	device:          Device,
	memory:          Memory,
}

Device_Memory_Stats_Args :: struct {
	struct_size:                   uint,
	extension_start:               ^Extension_Base,
	device:                        Device,
	bytes_in_use:                  i64,
	peak_bytes_in_use:             i64,
	peak_bytes_in_use_is_set:      b32,
	num_allocs:                    i64,
	num_allocs_is_set:             b32,
	largest_alloc_size:            i64,
	largest_alloc_size_is_set:     b32,
	bytes_limit:                   i64,
	bytes_limit_is_set:            b32,
	bytes_reserved:                i64,
	bytes_reserved_is_set:         b32,
	peak_bytes_reserved:           i64,
	peak_bytes_reserved_is_set:    b32,
	bytes_reservable_limit:        i64,
	bytes_reservable_limit_is_set: b32,
	largest_free_block_bytes:      i64,
	largest_free_block_bytes_is_set: b32,
	pool_bytes:                    i64,
	pool_bytes_is_set:             b32,
	peak_pool_bytes:               i64,
	peak_pool_bytes_is_set:        b32,
	peak_allocated_bytes:          i64,
	peak_allocated_bytes_is_set:   b32,
}

Device_Clear_Memory_Stats_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	device:          Device,
}

Device_Poison_Execution_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	device:             Device,
	launch_id:          i32,
	error_code:         Error_Code,
	error_message:      cstring,
	error_message_size: uint,
	poisoned:           b32,
	payload:            ^Named_Value,
	num_payload:        uint,
}

Device_Get_Attributes_Args :: struct {
	struct_size:         uint,
	extension_start:     ^Extension_Base,
	device:              Device,
	attributes:          ^Named_Value,
	num_attributes:      uint,
	device_attributes:   Device_Attributes,
	attributes_deleter:  proc "c" (device_attributes: Device_Attributes),
}

Device_Create_Async_Tracking_Event_Args :: struct {
	struct_size:       uint,
	extension_start:   ^Extension_Base,
	device:            Device,
	description:       cstring,
	description_size:  uint,
	event:             Async_Tracking_Event,
}

Async_Tracking_Event_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Async_Tracking_Event,
}

Async_Tracking_Event_On_Blocking_Start_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Async_Tracking_Event,
}

Async_Tracking_Event_On_Blocking_Ready_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	event:           Async_Tracking_Event,
}

// Memory Args
Memory_Id_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	memory:          Memory,
	id:              c.int,
}

Memory_Kind_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	memory:          Memory,
	kind:            cstring,
	kind_size:       uint,
}

Memory_Kind_Id_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	memory:          Memory,
	kind_id:         c.int,
}

Memory_Debug_String_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	memory:          Memory,
	debug_string:    cstring,
	debug_string_size: uint,
}

Memory_To_String_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	memory:          Memory,
	to_string:       cstring,
	to_string_size:  uint,
}

Memory_Addressable_By_Devices_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	memory:          Memory,
	devices:         [^]Device,
	num_devices:     uint,
}

// Executable Args
Executable_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
}

Executable_Name_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	executable:         Executable,
	executable_name:    cstring,
	executable_name_size: uint,
}

Executable_Num_Replicas_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	num_replicas:    uint,
}

Executable_Num_Partitions_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	num_partitions:  uint,
}

Executable_Num_Outputs_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	num_outputs:     uint,
}

Executable_Size_Of_Generated_Code_In_Bytes_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	size_in_bytes:   i64,
}

Executable_Serialize_Args :: struct {
	struct_size:                      uint,
	extension_start:                  ^Extension_Base,
	executable:                       Executable,
	serialized_bytes:                 cstring,
	serialized_bytes_size:            uint,
	serialized_executable:            Serialized_Executable,
	serialized_executable_deleter:    proc "c" (exec: Serialized_Executable),
}

Executable_Deserialize_And_Load_Args :: struct {
	struct_size:                            uint,
	extension_start:                        ^Extension_Base,
	client:                                 Client,
	serialized_executable:                  cstring,
	serialized_executable_size:             uint,
	loaded_executable:                      Loaded_Executable,
	overridden_serialized_compile_options:  cstring,
	overridden_serialized_compile_options_size: uint,
	load_options:                           rawptr,
}

Executable_Fingerprint_Args :: struct {
	struct_size:               uint,
	extension_start:           ^Extension_Base,
	executable:                Executable,
	executable_fingerprint:    cstring,
	executable_fingerprint_size: uint,
}

Executable_Get_Cost_Analysis_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	num_properties:  uint,
	properties:      ^Named_Value,
}

Executable_Output_Memory_Kinds_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	executable:         Executable,
	num_outputs:        uint,
	memory_kinds:       [^]cstring,
	memory_kind_sizes:  [^]uint,
}

Executable_Optimized_Program_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	program:         ^Program,
}

Executable_Get_Compiled_Memory_Stats_Args :: struct {
	struct_size:                      uint,
	extension_start:                  ^Extension_Base,
	executable:                       Executable,
	generated_code_size_in_bytes:     i64,
	argument_size_in_bytes:           i64,
	output_size_in_bytes:             i64,
	alias_size_in_bytes:              i64,
	temp_size_in_bytes:               i64,
	host_generated_code_size_in_bytes:  i64,
	host_argument_size_in_bytes:      i64,
	host_output_size_in_bytes:        i64,
	host_alias_size_in_bytes:         i64,
	host_temp_size_in_bytes:          i64,
	peak_memory_in_bytes:             i64,
	total_size_in_bytes:              i64,
	total_allocation_bytes:           i64,
	indefinite_allocations:           i64,
	peak_unpadded_heap_bytes:         i64,
}

Executable_Output_Element_Types_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	executable:           Executable,
	output_types:         [^]Buffer_Type,
	num_output_types:     uint,
}

Executable_Output_Dimensions_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Executable,
	num_outputs:     uint,
	dims:            [^]i64,
	dim_sizes:       [^]uint,
}

Executable_Parameter_Memory_Kinds_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	executable:         Executable,
	num_parameters:     uint,
	memory_kinds:       [^]cstring,
	memory_kind_sizes:  [^]uint,
}

Executable_Get_Compile_Options_Args :: struct {
	struct_size:                         uint,
	extension_start:                     ^Extension_Base,
	executable:                          Executable,
	serialized_bytes:                    cstring,
	serialized_bytes_size:               uint,
	serialized_compile_options:          Serialized_Compile_Options,
	serialized_compile_options_deleter:  proc "c" (options: Serialized_Compile_Options),
}

// Loaded Executable Args
Loaded_Executable_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Loaded_Executable,
}

Loaded_Executable_Get_Executable_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	loaded_executable:    Loaded_Executable,
	executable:           Executable,
}

Loaded_Executable_Addressable_Devices_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	executable:               Loaded_Executable,
	addressable_devices:      [^]Device,
	num_addressable_devices:  uint,
}

Loaded_Executable_Addressable_Device_Logical_Ids_Args :: struct {
	struct_size:                       uint,
	extension_start:                   ^Extension_Base,
	executable:                        Loaded_Executable,
	addressable_device_logical_ids:    [^]Logical_Device_Ids,
	num_addressable_device_logical_ids: uint,
}

Loaded_Executable_Delete_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Loaded_Executable,
}

Loaded_Executable_Is_Deleted_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	executable:      Loaded_Executable,
	is_deleted:      b32,
}

Send_Callback_Info :: struct {
	channel_id:     i64,
	user_arg:       rawptr,
	send_callback:  Send_Callback,
}

Recv_Callback_Info :: struct {
	channel_id:     i64,
	user_arg:       rawptr,
	recv_callback:  Recv_Callback,
}

Hlo_Output_Callback_Info :: struct {
	user_arg:      rawptr,
	callback:      Hlo_Output_Callback,
	callback_id:   i64,
	num_operands:  uint,
}

Execute_Options :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	send_callbacks:           [^]^Send_Callback_Info,
	recv_callbacks:           [^]^Recv_Callback_Info,
	num_send_ops:             uint,
	num_recv_ops:             uint,
	launch_id:                c.int,
	non_donatable_input_indices:       [^]i64,
	num_non_donatable_input_indices:   uint,
	ctx:                      Execute_Context,
	call_location:            cstring,
	num_tasks:                uint,
	task_ids:                 [^]c.int,
	incarnation_ids:          [^]i64,
	multi_slice_config:       ^Multi_Slice_Config,
	use_major_to_minor_data_layout_for_callbacks: b32,
	hlo_output_callbacks:     ^Hlo_Output_Callback_Info,
	num_hlo_output_callbacks: uint,
}

Load_Options :: struct {
	struct_size:              uint,
	computation_origin:       [^]i32,
	computation_origin_size:  uint,
	multi_slice_config:       ^Multi_Slice_Config,
}

Loaded_Executable_Execute_Args :: struct {
	struct_size:            uint,
	extension_start:        ^Extension_Base,
	executable:             Loaded_Executable,
	options:                ^Execute_Options,
	argument_lists:         [^][^]Buffer,
	num_devices:            uint,
	num_args:               uint,
	output_lists:           [^][^]Buffer,
	device_complete_events: [^]Event,
	execute_device:         Device,
}

Loaded_Executable_Get_Device_Assignment_Args :: struct {
	struct_size:                           uint,
	extension_start:                       ^Extension_Base,
	executable:                            Loaded_Executable,
	serialized_bytes:                      cstring,
	serialized_bytes_size:                 uint,
	serialized_device_assignment:          Device_Assignment_Serialized,
	serialized_device_assignment_deleter:  proc "c" (da: Device_Assignment_Serialized),
}

Loaded_Executable_Fingerprint_Args :: struct {
	struct_size:               uint,
	extension_start:           ^Extension_Base,
	executable:                Loaded_Executable,
	executable_fingerprint:    cstring,
	executable_fingerprint_size: uint,
}

// Buffer Args
Buffer_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
}

Buffer_Element_Type_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	type:            Buffer_Type,
}

Buffer_Dimensions_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	dims:            [^]i64,
	num_dims:        uint,
}

Buffer_Unpadded_Dimensions_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	unpadded_dims:   [^]i64,
	num_dims:        uint,
}

Buffer_Dynamic_Dimension_Indices_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	buffer:               Buffer,
	dynamic_dim_indices:  [^]uint,
	num_dynamic_dims:     uint,
}

Buffer_Get_Memory_Layout_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	layout:          Buffer_Memory_Layout,
}

Buffer_On_Device_Size_In_Bytes_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	buffer:                   Buffer,
	on_device_size_in_bytes:  uint,
}

Buffer_Device_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	device:          Device,
}

Buffer_Memory_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	memory:          Memory,
}

Buffer_Delete_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
}

Buffer_Is_Deleted_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	is_deleted:      b32,
}

Buffer_Copy_To_Device_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	dst_device:      Device,
	dst_buffer:      Buffer,
}

Buffer_Copy_To_Memory_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	dst_memory:      Memory,
	dst_buffer:      Buffer,
}

Buffer_To_Host_Buffer_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	src:             Buffer,
	host_layout:     ^Buffer_Memory_Layout,
	dst:             rawptr,
	dst_size:        uint,
	event:           Event,
}

Buffer_Is_On_Cpu_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	is_on_cpu:       b32,
}

Buffer_Ready_Event_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	event:           Event,
}

Buffer_Unsafe_Pointer_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	buffer_pointer:  uint,
}

Buffer_Increase_External_Reference_Count_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
}

Buffer_Decrease_External_Reference_Count_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
}

Buffer_Opaque_Device_Memory_Data_Pointer_Args :: struct {
	struct_size:               uint,
	extension_start:           ^Extension_Base,
	buffer:                    Buffer,
	device_memory_ptr:         rawptr,
}

Buffer_Copy_Raw_To_Host_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	dst:             rawptr,
	offset:          i64,
	transfer_size:   i64,
	event:           Event,
}

Buffer_Copy_Raw_To_Host_Future_Args :: struct {
	struct_size:           uint,
	extension_start:       ^Extension_Base,
	buffer:                Buffer,
	offset:                i64,
	transfer_size:         i64,
	event:                 Event,
	callback_data:         rawptr,
	future_ready_callback: proc "c" (args: ^Copy_Raw_To_Host_Future_Callback_Args),
}

Buffer_Bitcast_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	buffer:          Buffer,
	element_type:    Buffer_Type,
	dims:            [^]i64,
	num_dims:        uint,
	device_layout:   ^Buffer_Memory_Layout,
	out_buffer:      Buffer,
}

Buffer_Donate_With_Control_Dependency_Args :: struct {
	struct_size:                 uint,
	extension_start:             ^Extension_Base,
	buffer:                      Buffer,
	callback_data:               rawptr,
	dependency_ready_callback:   proc "c" (args: ^Donate_With_Control_Dependency_Callback_Args),
	out_buffer:                  Buffer,
}

// Copy To Device Stream Args
Copy_To_Device_Stream_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	stream:          Copy_To_Device_Stream,
}

Copy_To_Device_Stream_Add_Chunk_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	stream:             Copy_To_Device_Stream,
	chunk:              ^Chunk,
	transfer_complete:  Event,
}

Copy_To_Device_Stream_Total_Bytes_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	stream:          Copy_To_Device_Stream,
	total_bytes:     i64,
}

Copy_To_Device_Stream_Granule_Size_Args :: struct {
	struct_size:            uint,
	extension_start:        ^Extension_Base,
	stream:                 Copy_To_Device_Stream,
	granule_size_in_bytes:  i64,
}

Copy_To_Device_Stream_Current_Bytes_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	stream:          Copy_To_Device_Stream,
	current_bytes:   i64,
}

// Topology Description Args
Topology_Description_Create_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	topology_name:   cstring,
	topology_name_size: uint,
	create_options:  ^Named_Value,
	num_options:     uint,
	topology:        Topology_Description,
}

Topology_Description_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	topology:        Topology_Description,
}

Topology_Description_Platform_Version_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	topology:             Topology_Description,
	platform_version:     cstring,
	platform_version_size: uint,
}

Topology_Description_Platform_Name_Args :: struct {
	struct_size:       uint,
	extension_start:   ^Extension_Base,
	topology:          Topology_Description,
	platform_name:     cstring,
	platform_name_size: uint,
}

Topology_Description_Get_Device_Descriptions_Args :: struct {
	struct_size:         uint,
	extension_start:     ^Extension_Base,
	topology:            Topology_Description,
	descriptions:        [^]Device_Description,
	num_descriptions:    uint,
}

Topology_Description_Serialize_Args :: struct {
	struct_size:                   uint,
	extension_start:               ^Extension_Base,
	topology:                      Topology_Description,
	serialized_bytes:              cstring,
	serialized_bytes_size:         uint,
	serialized_topology:           Serialized_Topology,
	serialized_topology_deleter:   proc "c" (topology: Serialized_Topology),
}

Topology_Description_Deserialize_Args :: struct {
	struct_size:               uint,
	extension_start:           ^Extension_Base,
	serialized_topology:       cstring,
	serialized_topology_size:  uint,
	topology:                  Topology_Description,
}

Topology_Description_Attributes_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	topology:        Topology_Description,
	attributes:      ^Named_Value,
	num_attributes:  uint,
}

Topology_Description_Fingerprint_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	topology:        Topology_Description,
	fingerprint:     u64,
}

Topology_Description_Make_Canonical_Shape_For_Memory_Space_Args :: struct {
	struct_size:             uint,
	extension_start:         ^Extension_Base,
	topology:                Topology_Description,
	memory_space_kind_id:    c.int,
	dims:                    [^]i64,
	num_dims:                uint,
	element_type:            Buffer_Type,
	layout:                  ^Buffer_Memory_Layout,
	serialized_shape:        cstring,
	serialized_shape_size:   uint,
	serialized_shape_deleter: proc "c" (shape: cstring),
}

Topology_Description_Get_Memory_Space_Kind_Ids_Args :: struct {
	struct_size:                uint,
	extension_start:            ^Extension_Base,
	topology:                   Topology_Description,
	memory_space_kind_ids:      [^]c.int,
	num_memory_space_kind_ids:  uint,
}

// Compile Args
Compile_Args :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	topology:             Topology_Description,
	program:              ^Program,
	compile_options:      cstring,
	compile_options_size: uint,
	client:               Client,
	executable:           Executable,
}

// Execute Context Args
Execute_Context_Create_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	ctx:             Execute_Context,
}

Execute_Context_Destroy_Args :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	ctx:             Execute_Context,
}

// Async Host To Device Transfer Manager Args
Async_Host_To_Device_Transfer_Manager_Destroy_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
}

Async_Host_To_Device_Transfer_Manager_Transfer_Data_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	transfer_manager:         Async_Host_To_Device_Transfer_Manager,
	buffer_index:             c.int,
	data:                     rawptr,
	offset:                   i64,
	transfer_size:            i64,
	is_last_transfer:         b32,
	done_with_h2d_transfer:   Event,
}

Async_Host_To_Device_Transfer_Manager_Transfer_Literal_Args :: struct {
	struct_size:              uint,
	extension_start:          ^Extension_Base,
	transfer_manager:         Async_Host_To_Device_Transfer_Manager,
	buffer_index:             c.int,
	data:                     rawptr,
	shape_dims:               [^]i64,
	shape_num_dims:           uint,
	shape_element_type:       Buffer_Type,
	shape_layout:             ^Buffer_Memory_Layout,
	done_with_h2d_transfer:   Event,
}

Async_Host_To_Device_Transfer_Manager_Retrieve_Buffer_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
	buffer_index:       c.int,
	buffer_out:         Buffer,
}

Async_Host_To_Device_Transfer_Manager_Device_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
	device_out:         Device,
}

Async_Host_To_Device_Transfer_Manager_Buffer_Count_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
	buffer_count:       uint,
}

Async_Host_To_Device_Transfer_Manager_Buffer_Size_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
	buffer_index:       c.int,
	buffer_size:        uint,
}

Async_Host_To_Device_Transfer_Manager_Set_Buffer_Error_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
	buffer_index:       c.int,
	error_code:         Error_Code,
	error_message:      cstring,
	error_message_size: uint,
}

Async_Host_To_Device_Transfer_Manager_Add_Metadata_Args :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	transfer_manager:   Async_Host_To_Device_Transfer_Manager,
	transfer_metadata:  ^Named_Value,
	num_metadata:       uint,
}
