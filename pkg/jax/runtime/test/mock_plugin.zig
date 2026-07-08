const std = @import("std");
const jax = @import("jax");
const pjrt = jax.pjrt;

const MockClient = struct {
    platform_name: [:0]const u8 = "mock_cpu",
    platform_version: [:0]const u8 = "mock_version_1.0",
    devices: [1]*pjrt.Device = undefined,
    memories: [1]*pjrt.Memory = undefined,
    actual_devices: [1]MockDevice = .{MockDevice{}},
    actual_memories: [1]MockMemory = .{MockMemory{}},
};

const MockDevice = struct {
    id: i32 = 0,
    kind: [:0]const u8 = "mock_cpu",
    debug_string: [:0]const u8 = "mock_cpu:0",
};

const MockMemory = struct {
    id: i32 = 0,
    kind: [:0]const u8 = "mock_host_memory",
};

const MockBuffer = struct {
    client: *MockClient,
    device: *pjrt.Device,
    memory: ?*pjrt.Memory,
    dtype: pjrt.BufferType,
    dims: []const i64,
    data: []u8,
    is_deleted: bool = false,
};

const MockLoadedExecutable = struct {
    client: *MockClient,
    num_outputs: usize = 1,
};

const MockExecutable = struct {
    dummy: u32 = 0,
};

const MockEvent = struct {
    is_ready: bool = true,
};

const MockError = struct {
    code: pjrt.ErrorCode,
    message: [:0]const u8,
};

fn sizeInBytes(t: pjrt.BufferType) usize {
    return switch (t) {
        .invalid => 0,
        .pred => 1,
        .s8, .u8, .f8e5m2, .f8e4m3fn, .f8e4m3b11fnuz, .f8e5m2fnuz, .f8e4m3fnuz, .f8e4m3, .f8e3m4, .f8e8m0fnu, .f4e2m1fn => 1,
        .s16, .u16, .f16, .bf16 => 2,
        .s32, .u32, .f32 => 4,
        .s64, .u64, .f64, .c64 => 8,
        .c128 => 16,
        .s4, .u4 => 1,
        .s2, .u2 => 1,
        .s1, .u1 => 1,
        .token => 0,
    };
}

fn make_error(code: pjrt.ErrorCode, msg: []const u8) *pjrt.Error {
    const mock_err = std.heap.c_allocator.create(MockError) catch @panic("OOM");
    mock_err.* = .{
        .code = code,
        .message = std.heap.c_allocator.dupeSentinel(u8, msg, 0) catch @panic("OOM"),
    };
    return @ptrCast(mock_err);
}

fn mock_error_destroy(args: ?*pjrt.ErrorDestroyArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    if (a.@"error") |err_ptr| {
        const mock_err: *MockError = @ptrCast(@alignCast(err_ptr));
        std.heap.c_allocator.free(mock_err.message);
        std.heap.c_allocator.destroy(mock_err);
    }
    return null;
}

fn mock_error_message(args: ?*pjrt.ErrorMessageArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const mock_err: *MockError = @ptrCast(@alignCast(@constCast(a.@"error" orelse return null)));
    a.message = mock_err.message.ptr;
    a.message_size = mock_err.message.len;
    return null;
}

fn mock_client_create(args: ?*pjrt.ClientCreateArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client = std.heap.c_allocator.create(MockClient) catch |e| return make_error(.resource_exhausted, @errorName(e));
    client.* = MockClient{};
    client.devices[0] = @ptrCast(&client.actual_devices[0]);
    client.memories[0] = @ptrCast(&client.actual_memories[0]);
    a.client = @ptrCast(client);
    return null;
}

fn mock_client_destroy(args: ?*pjrt.ClientDestroyArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    if (a.client) |c_ptr| {
        const client: *MockClient = @ptrCast(@alignCast(c_ptr));
        std.heap.c_allocator.destroy(client);
    }
    return null;
}

fn mock_client_platform_name(args: ?*pjrt.ClientPlatformNameArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));
    a.platform_name = client.platform_name.ptr;
    a.platform_name_size = client.platform_name.len;
    return null;
}

fn mock_client_platform_version(args: ?*pjrt.ClientPlatformVersionArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));
    a.platform_version = client.platform_version.ptr;
    a.platform_version_size = client.platform_version.len;
    return null;
}

fn mock_client_process_index(args: ?*pjrt.ClientProcessIndexArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    a.process_index = 0;
    return null;
}

fn mock_client_devices(args: ?*pjrt.ClientDevicesArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));
    a.devices = @ptrCast(&client.devices[0]);
    a.num_devices = 1;
    return null;
}

fn mock_client_addressable_memories(args: ?*pjrt.ClientAddressableMemoriesArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));
    a.addressable_memories = @ptrCast(&client.memories[0]);
    a.num_addressable_memories = 1;
    return null;
}

fn mock_client_buffer_from_host_buffer(args: ?*pjrt.ClientBufferFromHostBufferArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));

    var num_elements: usize = 1;
    var i: usize = 0;
    while (i < a.num_dims) : (i += 1) {
        num_elements *= @intCast(a.dims[i]);
    }

    const size_in_bytes = num_elements * sizeInBytes(a.type_);

    const data_copy = std.heap.c_allocator.alloc(u8, size_in_bytes) catch |e| return make_error(.resource_exhausted, @errorName(e));
    errdefer std.heap.c_allocator.free(data_copy);
    const raw_src: [*]const u8 = @ptrCast(a.data);
    @memcpy(data_copy, raw_src[0..size_in_bytes]);

    const dims_copy = std.heap.c_allocator.alloc(i64, a.num_dims) catch |e| return make_error(.resource_exhausted, @errorName(e));
    errdefer std.heap.c_allocator.free(dims_copy);
    @memcpy(dims_copy, a.dims[0..a.num_dims]);

    const buffer = std.heap.c_allocator.create(MockBuffer) catch |e| return make_error(.resource_exhausted, @errorName(e));
    buffer.* = .{
        .client = client,
        .device = a.device orelse return make_error(.invalid_argument, "device is null"),
        .memory = a.memory,
        .dtype = a.type_,
        .dims = dims_copy,
        .data = data_copy,
    };

    const out_buf_ptr: *?*pjrt.Buffer = @ptrCast(@alignCast(a.buffer));
    out_buf_ptr.* = @ptrCast(buffer);

    const event = std.heap.c_allocator.create(MockEvent) catch |e| return make_error(.resource_exhausted, @errorName(e));
    event.* = .{ .is_ready = true };
    const out_event_ptr: *?*pjrt.Event = @ptrCast(@alignCast(a.done_with_host_buffer));
    out_event_ptr.* = @ptrCast(event);

    return null;
}

fn mock_buffer_destroy(args: ?*pjrt.BufferDestroyArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    if (a.buffer) |b_ptr| {
        const buffer: *MockBuffer = @ptrCast(@alignCast(b_ptr));
        std.heap.c_allocator.free(buffer.dims);
        std.heap.c_allocator.free(buffer.data);
        std.heap.c_allocator.destroy(buffer);
    }
    return null;
}

fn mock_buffer_to_host_buffer(args: ?*pjrt.BufferToHostBufferArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.src orelse return null));
    const dst: [*]u8 = @ptrCast(a.dst orelse return null);
    @memcpy(dst[0..a.dst_size], buffer.data[0..a.dst_size]);

    const event = std.heap.c_allocator.create(MockEvent) catch |e| return make_error(.resource_exhausted, @errorName(e));
    event.* = .{ .is_ready = true };
    const out_event_ptr: *?*pjrt.Event = @ptrCast(@alignCast(a.event));
    out_event_ptr.* = @ptrCast(event);
    return null;
}

fn mock_buffer_on_device_size_in_bytes(args: ?*pjrt.BufferOnDeviceSizeInBytesArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));
    a.on_device_size_in_bytes = buffer.data.len;
    return null;
}

fn mock_buffer_is_on_cpu(args: ?*pjrt.BufferIsOnCpuArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    a.is_on_cpu = true;
    return null;
}

fn mock_buffer_copy_to_device(args: ?*pjrt.BufferCopyToDeviceArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));

    const data_copy = std.heap.c_allocator.alloc(u8, buffer.data.len) catch |e| return make_error(.resource_exhausted, @errorName(e));
    errdefer std.heap.c_allocator.free(data_copy);
    @memcpy(data_copy, buffer.data);

    const dims_copy = std.heap.c_allocator.alloc(i64, buffer.dims.len) catch |e| return make_error(.resource_exhausted, @errorName(e));
    errdefer std.heap.c_allocator.free(dims_copy);
    @memcpy(dims_copy, buffer.dims);

    const new_buffer = std.heap.c_allocator.create(MockBuffer) catch |e| return make_error(.resource_exhausted, @errorName(e));
    new_buffer.* = .{
        .client = buffer.client,
        .device = a.dst_device orelse return make_error(.invalid_argument, "dst_device is null"),
        .memory = null,
        .dtype = buffer.dtype,
        .dims = dims_copy,
        .data = data_copy,
    };

    const out_buf_ptr: *?*pjrt.Buffer = @ptrCast(@alignCast(a.dst_buffer));
    out_buf_ptr.* = @ptrCast(new_buffer);
    return null;
}

fn mock_buffer_device(args: ?*pjrt.BufferDeviceArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));
    a.device = buffer.device;
    return null;
}

fn mock_buffer_delete(args: ?*pjrt.BufferDeleteArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));
    buffer.is_deleted = true;
    return null;
}

fn mock_buffer_is_deleted(args: ?*pjrt.BufferIsDeletedArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));
    a.is_deleted = buffer.is_deleted;
    return null;
}

fn mock_buffer_element_type(args: ?*pjrt.BufferElementTypeArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));
    a.type_ = buffer.dtype;
    return null;
}

fn mock_buffer_dimensions(args: ?*pjrt.BufferDimensionsArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const buffer: *MockBuffer = @ptrCast(@alignCast(a.buffer orelse return null));
    a.dims = buffer.dims.ptr;
    a.num_dims = buffer.dims.len;
    return null;
}

fn mock_client_compile(args: ?*pjrt.ClientCompileArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));

    const loaded = std.heap.c_allocator.create(MockLoadedExecutable) catch |e| return make_error(.resource_exhausted, @errorName(e));
    loaded.* = .{
        .client = client,
        .num_outputs = 1,
    };
    const out_exec_ptr: *?*pjrt.LoadedExecutable = @ptrCast(@alignCast(a.executable));
    out_exec_ptr.* = @ptrCast(loaded);
    return null;
}

fn mock_executable_deserialize_and_load(args: ?*pjrt.ExecutableDeserializeAndLoadArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const client: *MockClient = @ptrCast(@alignCast(a.client orelse return null));

    const loaded = std.heap.c_allocator.create(MockLoadedExecutable) catch |e| return make_error(.resource_exhausted, @errorName(e));
    loaded.* = .{
        .client = client,
        .num_outputs = 1,
    };
    const out_exec_ptr: *?*pjrt.LoadedExecutable = @ptrCast(@alignCast(a.loaded_executable));
    out_exec_ptr.* = @ptrCast(loaded);
    return null;
}

fn mock_loaded_executable_destroy(args: ?*pjrt.LoadedExecutableDestroyArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    if (a.loaded_executable) |le_ptr| {
        const loaded: *MockLoadedExecutable = @ptrCast(@alignCast(le_ptr));
        std.heap.c_allocator.destroy(loaded);
    }
    return null;
}

fn mock_executable_num_outputs(args: ?*pjrt.ExecutableNumOutputsArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const loaded: *MockLoadedExecutable = @ptrCast(@alignCast(a.executable orelse return null));
    a.num_outputs = loaded.num_outputs;
    return null;
}

fn mock_loaded_executable_get_executable(args: ?*pjrt.LoadedExecutableGetExecutableArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const dummy_exec = std.heap.c_allocator.create(MockExecutable) catch |e| return make_error(.resource_exhausted, @errorName(e));
    dummy_exec.* = .{};
    const out_exec_ptr: *?*pjrt.Executable = @ptrCast(@alignCast(a.executable));
    out_exec_ptr.* = @ptrCast(dummy_exec);
    return null;
}

fn mock_loaded_executable_addressable_devices(args: ?*pjrt.LoadedExecutableAddressableDevicesArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const loaded: *MockLoadedExecutable = @ptrCast(@alignCast(a.loaded_executable orelse return null));
    a.addressable_devices[0] = @ptrCast(loaded.client.devices[0]);
    a.num_addressable_devices = 1;
    return null;
}

fn mock_loaded_executable_fingerprint(args: ?*pjrt.LoadedExecutableFingerprintArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const fp: [:0]const u8 = "mock_fingerprint";
    a.executable_fingerprint = fp.ptr;
    a.executable_fingerprint_size = fp.len;
    return null;
}

fn mock_loaded_executable_execute(args: ?*pjrt.LoadedExecutableExecuteArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    const loaded: *MockLoadedExecutable = @ptrCast(@alignCast(a.executable orelse return null));

    const outputs: [*]?*pjrt.Buffer = a.output_lists[0];

    var first_buf: ?*MockBuffer = null;
    if (a.num_args > 0) {
        const inputs = a.argument_lists[0];
        if (inputs[0]) |in_ptr| {
            first_buf = @ptrCast(@alignCast(in_ptr));
        }
    }

    var i: usize = 0;
    while (i < loaded.num_outputs) : (i += 1) {
        var data: []u8 = undefined;
        var dims: []i64 = undefined;
        var dtype: pjrt.BufferType = .f32;

        if (first_buf) |fb| {
            data = std.heap.c_allocator.alloc(u8, fb.data.len) catch |e| return make_error(.resource_exhausted, @errorName(e));
            errdefer std.heap.c_allocator.free(data);
            @memcpy(data, fb.data);

            if (fb.dtype == .f32) {
                const floats = std.mem.bytesAsSlice(f32, data);
                for (floats) |*val| val.* += 1.0;
            }

            dims = std.heap.c_allocator.alloc(i64, fb.dims.len) catch |e| return make_error(.resource_exhausted, @errorName(e));
            errdefer std.heap.c_allocator.free(dims);
            @memcpy(dims, fb.dims);
            dtype = fb.dtype;
        } else {
            data = std.heap.c_allocator.alloc(u8, 4) catch |e| return make_error(.resource_exhausted, @errorName(e));
            errdefer std.heap.c_allocator.free(data);
            const val: f32 = 42.0;
            @memcpy(data, std.mem.asBytes(&val));

            dims = std.heap.c_allocator.alloc(i64, 0) catch |e| return make_error(.resource_exhausted, @errorName(e));
            errdefer std.heap.c_allocator.free(dims);
            dtype = .f32;
        }

        const out_buf = std.heap.c_allocator.create(MockBuffer) catch |e| return make_error(.resource_exhausted, @errorName(e));
        out_buf.* = .{
            .client = loaded.client,
            .device = a.execute_device orelse return make_error(.invalid_argument, "execute_device is null"),
            .memory = null,
            .dtype = dtype,
            .dims = dims,
            .data = data,
        };
        outputs[i] = @ptrCast(out_buf);
    }

    const event = std.heap.c_allocator.create(MockEvent) catch |e| return make_error(.resource_exhausted, @errorName(e));
    event.* = .{ .is_ready = true };
    a.device_complete_events[0] = @ptrCast(event);

    return null;
}

fn mock_event_await(args: ?*pjrt.EventAwaitArgs) callconv(.c) ?*pjrt.Error {
    _ = args;
    return null;
}

fn mock_event_destroy(args: ?*pjrt.EventDestroyArgs) callconv(.c) ?*pjrt.Error {
    const a = args orelse return null;
    if (a.event) |ev_ptr| {
        const ev: *MockEvent = @ptrCast(@alignCast(ev_ptr));
        std.heap.c_allocator.destroy(ev);
    }
    return null;
}

fn mock_event_error(args: ?*pjrt.EventErrorArgs) callconv(.c) ?*pjrt.Error {
    _ = args;
    return null;
}

const mock_api = pjrt.Api{
    .struct_size = @sizeOf(pjrt.Api),
    .extension_start = null,
    .pjrt_api_version = .{
        .struct_size = @sizeOf(pjrt.ApiVersion),
        .extension_start = null,
        .major_version = 0,
        .minor_version = 1,
    },
    .error_destroy = mock_error_destroy,
    .error_message = mock_error_message,
    .error_get_code = undefined,
    .plugin_initialize = undefined,
    .plugin_attributes = undefined,
    .client_create = mock_client_create,
    .client_destroy = mock_client_destroy,
    .client_platform_name = mock_client_platform_name,
    .client_platform_version = mock_client_platform_version,
    .client_process_index = mock_client_process_index,
    .client_devices = mock_client_devices,
    .client_addressable_devices = undefined,
    .client_lookup_device = undefined,
    .client_lookup_addressable_device = undefined,
    .client_addressable_memories = mock_client_addressable_memories,
    .client_compile = mock_client_compile,
    .client_default_device_assignment = undefined,
    .client_buffer_from_host_buffer = mock_client_buffer_from_host_buffer,
    .client_create_view_of_device_buffer = undefined,
    .client_dma_map = undefined,
    .client_dma_unmap = undefined,
    .client_topology_description = undefined,
    .client_create_buffers_for_async_host_to_device = undefined,
    .device_description_id = undefined,
    .device_description_process_index = undefined,
    .device_description_attributes = undefined,
    .device_description_kind = undefined,
    .device_description_debug_string = undefined,
    .device_description_to_string = undefined,
    .device_get_description = undefined,
    .device_is_addressable = undefined,
    .device_local_hardware_id = undefined,
    .device_addressable_memories = undefined,
    .device_default_memory = undefined,
    .device_memory_stats = undefined,
    .device_clear_memory_stats = undefined,
    .device_poison_execution = undefined,
    .device_create_async_tracking_event = undefined,
    .device_get_attributes = undefined,
    .async_tracking_event_destroy = undefined,
    .memory_id = undefined,
    .memory_kind = undefined,
    .memory_debug_string = undefined,
    .memory_to_string = undefined,
    .memory_addressable_by_devices = undefined,
    .executable_destroy = undefined,
    .executable_name = undefined,
    .executable_num_replicas = undefined,
    .executable_num_partitions = undefined,
    .executable_num_outputs = mock_executable_num_outputs,
    .executable_size_of_generated_code_in_bytes = undefined,
    .executable_serialize = undefined,
    .executable_deserialize_and_load = mock_executable_deserialize_and_load,
    .executable_fingerprint = undefined,
    .executable_get_cost_analysis = undefined,
    .executable_output_memory_kinds = undefined,
    .executable_get_compiled_memory_stats = undefined,
    .loaded_executable_destroy = mock_loaded_executable_destroy,
    .loaded_executable_get_executable = mock_loaded_executable_get_executable,
    .loaded_executable_addressable_devices = mock_loaded_executable_addressable_devices,
    .loaded_executable_delete = undefined,
    .loaded_executable_is_deleted = undefined,
    .loaded_executable_execute = mock_loaded_executable_execute,
    .loaded_executable_fingerprint = mock_loaded_executable_fingerprint,
    .loaded_executable_get_device_assignment = undefined,
    .buffer_destroy = mock_buffer_destroy,
    .buffer_element_type = mock_buffer_element_type,
    .buffer_dimensions = mock_buffer_dimensions,
    .buffer_unpadded_dimensions = undefined,
    .buffer_dynamic_dimension_indices = undefined,
    .buffer_get_memory_layout = undefined,
    .buffer_on_device_size_in_bytes = mock_buffer_on_device_size_in_bytes,
    .buffer_device = mock_buffer_device,
    .buffer_memory = undefined,
    .buffer_delete = mock_buffer_delete,
    .buffer_is_deleted = mock_buffer_is_deleted,
    .buffer_copy_to_device = mock_buffer_copy_to_device,
    .buffer_to_host_buffer = mock_buffer_to_host_buffer,
    .buffer_is_on_cpu = mock_buffer_is_on_cpu,
    .buffer_ready_event = undefined,
    .buffer_unsafe_pointer = undefined,
    .buffer_increase_external_reference_count = undefined,
    .buffer_decrease_external_reference_count = undefined,
    .buffer_opaque_device_memory_data_pointer = undefined,
    .event_destroy = mock_event_destroy,
    .event_is_ready = undefined,
    .event_error = mock_event_error,
    .event_await = mock_event_await,
    .event_on_ready = undefined,
    .event_create = undefined,
    .copy_to_device_stream_destroy = undefined,
    .copy_to_device_stream_add_chunk = undefined,
    .copy_to_device_stream_total_bytes = undefined,
    .copy_to_device_stream_granule_size = undefined,
    .copy_to_device_stream_current_bytes = undefined,
    .topology_description_destroy = undefined,
    .topology_description_platform_name = undefined,
    .topology_description_platform_version = undefined,
    .topology_description_get_device_descriptions = undefined,
    .topology_description_serialize = undefined,
    .topology_description_deserialize = undefined,
    .topology_description_attributes = undefined,
    .topology_description_fingerprint = undefined,
    .topology_description_make_canonical_shape_for_memory_space = undefined,
    .topology_description_get_memory_space_kind_ids = undefined,
    .buffer_copy_to_memory = undefined,
    .buffer_copy_raw_to_host = undefined,
    .async_host_to_device_transfer_manager_destroy = undefined,
    .async_host_to_device_transfer_manager_transfer_data = undefined,
    .async_host_to_device_transfer_manager_retrieve_buffer = undefined,
    .async_host_to_device_transfer_manager_device = undefined,
    .async_host_to_device_transfer_manager_buffer_count = undefined,
    .async_host_to_device_transfer_manager_buffer_size = undefined,
    .async_host_to_device_transfer_manager_set_buffer_error = undefined,
    .async_host_to_device_transfer_manager_add_metadata = undefined,
    .async_host_to_device_transfer_manager_transfer_literal = undefined,
    .buffer_copy_raw_to_host_future = undefined,
    .buffer_donate_with_control_dependency = undefined,
    .buffer_bitcast = undefined,
    .executable_output_element_types = undefined,
    .executable_output_dimensions = undefined,
    .executable_get_compile_options = undefined,
    .executable_parameter_memory_kinds = undefined,
    .loaded_executable_addressable_device_logical_ids = undefined,
    .error_for_each_payload = undefined,
    .executable_optimized_program = undefined,
    .topology_description_create = undefined,
    .compile = undefined,
    .memory_kind_id = undefined,
    .execute_context_create = undefined,
    .execute_context_destroy = undefined,
    .event_set = undefined,
    .client_load = undefined,
    .client_create_uninitialized_buffer = undefined,
    .client_update_global_process_info = undefined,
    .client_create_alias_buffer = undefined,
    .client_fulfill_alias_buffer = undefined,
    .client_create_error_buffer = undefined,
};

pub export fn GetPjrtApi() callconv(.c) *const pjrt.Api {
    return &mock_api;
}
