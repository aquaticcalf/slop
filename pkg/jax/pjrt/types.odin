package pjrt

import "core:c"

when ODIN_OS == .Windows {
	foreign import dl "kernel32.dll"
} else {
	foreign import dl "system:dl"
}

@(default_calling_convention = "c")
foreign dl {
	when ODIN_OS == .Windows {
		LoadLibraryA   :: proc(filename: cstring) -> rawptr ---
		GetProcAddress  :: proc(module: rawptr, name: cstring) -> rawptr ---
		FreeLibrary    :: proc(module: rawptr) -> bool ---
	} else {
		dlopen  :: proc(filename: cstring, flags: c.int) -> rawptr ---
		dlsym   :: proc(handle: rawptr, symbol: cstring) -> rawptr ---
		dlclose :: proc(handle: rawptr) -> c.int ---
	}
}

// Opaque Handles
Error                           :: struct {}
Client                          :: struct {}
Device                          :: struct {}
Memory                          :: struct {}
Buffer                          :: struct {}
Event                           :: struct {}
Executable                      :: struct {}
Loaded_Executable               :: struct {}
Device_Description              :: struct {}
Topology_Description            :: struct {}
Execute_Context                 :: struct {}
Serialized_Executable           :: struct {}
Async_Host_To_Device_Transfer_Manager :: struct {}
Async_Tracking_Event            :: struct {}
Multi_Slice_Config              :: struct {}
Phase_Compiler                  :: struct {}
Copy_To_Device_Stream           :: struct {}
Serialized_Topology             :: struct {}
Fulfill_Alias_Buffer_Callback   :: struct {}
Device_Attributes               :: struct {}
Device_Assignment_Serialized    :: struct {}

// Enums
Error_Code :: enum c.int {
	OK                 = 0,
	CANCELLED          = 1,
	UNKNOWN            = 2,
	INVALID_ARGUMENT   = 3,
	DEADLINE_EXCEEDED  = 4,
	NOT_FOUND          = 5,
	ALREADY_EXISTS     = 6,
	PERMISSION_DENIED  = 7,
	RESOURCE_EXHAUSTED = 8,
	FAILED_PRECONDITION = 9,
	ABORTED            = 10,
	OUT_OF_RANGE       = 11,
	UNIMPLEMENTED      = 12,
	INTERNAL           = 13,
	UNAVAILABLE        = 14,
	DATA_LOSS          = 15,
	UNAUTHENTICATED    = 16,
}

Buffer_Type :: enum c.int {
	INVALID       = 0,
	PRED          = 1,
	S8            = 2,
	S16           = 3,
	S32           = 4,
	S64           = 5,
	U8            = 6,
	U16           = 7,
	U32           = 8,
	U64           = 9,
	F16           = 10,
	F32           = 11,
	F64           = 12,
	BF16          = 13,
	C64           = 14,
	C128          = 15,
	F8E5M2        = 16,
	F8E4M3FN      = 17,
	F8E4M3B11FNUZ = 18,
	F8E5M2FNUZ    = 19,
	F8E4M3FNUZ    = 20,
	S4            = 21,
	U4            = 22,
	TOKEN         = 23,
	S2            = 24,
	U2            = 25,
	F8E4M3        = 26,
	F8E3M4        = 27,
	F8E8M0FNU     = 28,
	F4E2M1FN      = 29,
	S1            = 30,
	U1            = 31,
}

Host_Buffer_Semantics :: enum c.int {
	IMMUTABLE_ONLY_DURING_CALL             = 0,
	IMMUTABLE_UNTIL_TRANSFER_COMPLETES     = 1,
	IMMUTABLE_ZERO_COPY                    = 2,
	MUTABLE_ZERO_COPY                      = 3,
}

Named_Value_Type :: enum c.int {
	STRING     = 0,
	INT64      = 1,
	INT64_LIST = 2,
	FLOAT      = 3,
	BOOL       = 4,
}

Extension_Type :: enum c.int {
	GPU_CUSTOM_CALL         = 0,
	PROFILER                = 1,
	CUSTOM_PARTITIONER      = 2,
	STREAM                  = 3,
	LAYOUTS                 = 4,
	FFI                     = 5,
	MEMORY_DESCRIPTIONS     = 6,
	TRITON                  = 7,
	RAW_BUFFER              = 8,
	PHASE_COMPILE           = 9,
	EXAMPLE                 = 10,
	UNKNOWN                 = 11,
	CROSS_HOST_TRANSFERS    = 12,
	EXECUTABLE_METADATA     = 13,
	CALLBACK                = 14,
	HOST_ALLOCATOR          = 15,
	TPU_TOPOLOGY            = 16,
	TPU_EXECUTABLE          = 17,
	MEGASCALE               = 18,
	SHARDINGS               = 19,
	ABI_VERSION             = 20,
	COLLECTIVES             = 21,
	MULTI_SLICE             = 22,
	HOST_MEMORY_ALLOCATOR   = 23,
	XLA_TRANSFORM           = 24,
}

Buffer_Memory_Layout_Type :: enum c.int {
	TILED   = 0,
	STRIDES = 1,
}

Process_State :: enum c.int {
	UNSPECIFIED   = 0,
	UNINITIALIZED = 1,
	DISCONNECTED  = 2,
	CONNECTED     = 3,
	ERROR         = 4,
}

// Complex C Struct Mappings
Extension_Base :: struct {
	struct_size:     uint,
	type:            Extension_Type,
	next:            ^Extension_Base,
}

Named_Value :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	name:            cstring,
	name_size:       uint,
	type:            Named_Value_Type,
	value:           struct #raw_union {
		string_value:       cstring,
		int64_value:        i64,
		int64_array_value:  [^]i64,
		float_value:        f32,
		bool_value:         b32,
	},
	value_size:      uint,
}

Api_Version :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	major_version:   c.int,
	minor_version:   c.int,
}

Buffer_Memory_Layout_Tiled :: struct {
	struct_size:        uint,
	extension_start:    ^Extension_Base,
	minor_to_major:     [^]i64,
	minor_to_major_size: uint,
	tile_dims:          [^]i64,
	tile_dim_sizes:     [^]uint,
	num_tiles:          uint,
}

Buffer_Memory_Layout_Strides :: struct {
	struct_size:       uint,
	extension_start:   ^Extension_Base,
	byte_strides:      [^]i64,
	num_byte_strides:  uint,
}

Buffer_Memory_Layout :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	layout:          struct #raw_union {
		tiled:   Buffer_Memory_Layout_Tiled,
		strides: Buffer_Memory_Layout_Strides,
	},
	type:            Buffer_Memory_Layout_Type,
}

Shape_Spec :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	dims:            [^]i64,
	num_dims:        uint,
	element_type:    Buffer_Type,
}

Program :: struct {
	struct_size:     uint,
	extension_start: ^Extension_Base,
	code:            [^]u8,
	code_size:       uint,
	format:          cstring,
	format_size:     uint,
}

Process_Info :: struct {
	struct_size:        uint,
	task_id:            c.int,
	incarnation_id:     u64,
	state:              Process_State,
	error_code:         c.int,
	error_message:      cstring,
	error_message_size: uint,
}

Serialized_Compile_Options :: struct {
	struct_size:                       uint,
	extension_start:                   ^Extension_Base,
	serialized_compile_options:        cstring,
	serialized_compile_options_size:   uint,
}

Error_Function_Table :: struct {
	struct_size:      uint,
	instance_size:    uint,
	extension_start:  ^Extension_Base,
	destroy:          proc "c" (error: Error),
	message:          proc "c" (error: Error, message: ^cstring, message_size: ^uint),
	get_code:         proc "c" (error: Error) -> Error_Code,
	for_each_payload: proc "c" (error: Error, visitor: Error_Payload_Visitor, user_arg: rawptr),
}

Error_VTable :: struct {
	vtable: Error_Function_Table,
}

Memory_Function_Table :: struct {
	struct_size:          uint,
	extension_start:      ^Extension_Base,
	instance_struct_size: uint,
	get_user_data:        proc "c" (memory: Memory, key: rawptr) -> rawptr,
	set_user_data:        proc "c" (memory: Memory, key: rawptr, data: rawptr, dtor: proc "c" (data: rawptr)),
}

Memory_VTable :: struct {
	vtable: Memory_Function_Table,
}

Chunk :: struct {
	data:        rawptr,
	size:        uint,
	deleter:     proc "c" (data: rawptr, deleter_arg: rawptr),
	deleter_arg: rawptr,
}

Logical_Device_Ids :: struct {
	replica:   c.int,
	partition: c.int,
}

Error_Payload_Visitor :: #type proc "c" (key: cstring, key_size: uint, value: cstring, value_size: uint, user_arg: rawptr)

Copy_Raw_To_Host_Future_Callback_Args :: struct {
	struct_size:    uint,
	callback_data:  rawptr,
	error_code:     Error_Code,
	error_message:  cstring,
	error_message_size: uint,
	dst:            rawptr,
}

Donate_With_Control_Dependency_Callback_Args :: struct {
	struct_size:       uint,
	callback_data:     rawptr,
	error_code:        Error_Code,
	error_message:     cstring,
	error_message_size: uint,
}

// Callback Types
Callback_Error :: #type proc "c" (code: Error_Code, message: cstring, message_size: uint) -> Error

Key_Value_Get_Callback_Value_Deleter :: #type proc "c" (value: cstring)
Key_Value_Try_Get_Callback_Value_Deleter :: #type proc "c" (value: cstring)

Send_Callback :: #type proc "c" (chunk: ^Chunk, callback_error: ^Callback_Error, total_size_in_bytes: uint, done: b32, user_arg: rawptr) -> Error
Recv_Callback :: #type proc "c" (stream: Copy_To_Device_Stream, user_arg: rawptr)
Hlo_Output_Callback :: #type proc "c" (replica_id: i64, partition_id: i64, data: rawptr, shape_dims: [^]i64, shape_num_dims: uint, shape_element_type: Buffer_Type, operand_index: i64, user_arg: rawptr)
Event_On_Ready_Callback :: #type proc "c" (error: Error, user_arg: rawptr)
Key_Value_Get_Callback :: #type proc "c" (args: ^Key_Value_Get_Callback_Args) -> Error
Key_Value_Try_Get_Callback :: #type proc "c" (args: ^Key_Value_Try_Get_Callback_Args) -> Error
Key_Value_Put_Callback :: #type proc "c" (args: ^Key_Value_Put_Callback_Args) -> Error
