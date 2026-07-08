const std = @import("std");
const jax = @import("jax");
const runtime = @import("runtime");

test "DType sizeInBytes" {
    try std.testing.expectEqual(@as(usize, 0), runtime.DType.invalid.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 1), runtime.DType.pred.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 1), runtime.DType.s8.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 2), runtime.DType.s16.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 4), runtime.DType.s32.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 8), runtime.DType.s64.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 1), runtime.DType.u8.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 2), runtime.DType.u16.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 4), runtime.DType.u32.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 8), runtime.DType.u64.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 2), runtime.DType.f16.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 4), runtime.DType.f32.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 8), runtime.DType.f64.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 2), runtime.DType.bf16.sizeInBytes());
    try std.testing.expectEqual(@as(usize, 0), runtime.DType.token.sizeInBytes());
}

test "DType toBufferType roundtrip" {
    const cases: []const runtime.DType = &.{
        .invalid, .pred, .s8,  .s16,  .s32,   .s64,
        .u8,      .u16,  .u32, .u64,  .f16,   .f32,
        .f64,     .bf16, .c64, .c128, .token,
    };
    for (cases) |dt| {
        const bt = dt.toBufferType();
        const dt2 = runtime.DType.fromBufferType(bt);
        try std.testing.expectEqual(@intFromEnum(dt), @intFromEnum(dt2));
    }
}

test "Shape numElements" {
    const shape = runtime.Shape{
        .dims = &.{ 2, 3, 4 },
        .dtype = .f32,
    };
    try std.testing.expectEqual(@as(usize, 24), shape.numElements());
}

test "Shape sizeInBytes" {
    const shape = runtime.Shape{
        .dims = &.{ 2, 3, 4 },
        .dtype = .f32,
    };
    try std.testing.expectEqual(@as(usize, 96), shape.sizeInBytes());
}

test "Shape numElements empty dims" {
    const shape = runtime.Shape{
        .dims = &.{},
        .dtype = .f32,
    };
    try std.testing.expectEqual(@as(usize, 1), shape.numElements());
}

test "Shape sizeInBytes scalar" {
    const shape = runtime.Shape{
        .dims = &.{},
        .dtype = .f64,
    };
    try std.testing.expectEqual(@as(usize, 8), shape.sizeInBytes());
}

test "DType to BufferType name parity" {
    try std.testing.expectEqual(@intFromEnum(jax.pjrt.BufferType.invalid), @intFromEnum(runtime.DType.invalid.toBufferType()));
    try std.testing.expectEqual(@intFromEnum(jax.pjrt.BufferType.f32), @intFromEnum(runtime.DType.f32.toBufferType()));
    try std.testing.expectEqual(@intFromEnum(jax.pjrt.BufferType.f64), @intFromEnum(runtime.DType.f64.toBufferType()));
    try std.testing.expectEqual(@intFromEnum(jax.pjrt.BufferType.bf16), @intFromEnum(runtime.DType.bf16.toBufferType()));
    try std.testing.expectEqual(@intFromEnum(jax.pjrt.BufferType.s32), @intFromEnum(runtime.DType.s32.toBufferType()));
    try std.testing.expectEqual(@intFromEnum(jax.pjrt.BufferType.u8), @intFromEnum(runtime.DType.u8.toBufferType()));
}

test "Plugin init error on invalid path" {
    _ = runtime.Plugin.init("nonexistent_plugin.xyz") catch |err| {
        try std.testing.expect(err == error.FileNotFound or
            err == error.NoPjrtApi or
            err == error.NameTooLong);
        return;
    };
    return error.PluginShouldNotHaveLoaded;
}

fn getMockPluginPath() []const u8 {
    const paths = [_][]const u8{
        "zig-out/bin/mock_pjrt.dll",
        "zig-out/lib/libmock_pjrt.so",
        "zig-out/lib/libmock_pjrt.dylib",
    };
    for (paths) |p| {
        var plugin = runtime.Plugin.init(p) catch continue;
        plugin.deinit();
        return p;
    }
    return "zig-out/bin/mock_pjrt.dll";
}

test "plugin.load_cpu" {
    const path = getMockPluginPath();
    var plugin = try runtime.Plugin.init(path);
    defer plugin.deinit();
    try std.testing.expect(plugin.api.struct_size >= @sizeOf(jax.pjrt.Api));
}

test "client.create_and_query" {
    const path = getMockPluginPath();
    var plugin = try runtime.Plugin.init(path);
    defer plugin.deinit();

    var client = try runtime.Client.init(&plugin, std.testing.allocator);
    defer client.deinit();

    const name = try client.platformName();
    try std.testing.expect(std.mem.indexOf(u8, name, "mock_cpu") != null);

    const version = try client.platformVersion();
    try std.testing.expectEqualSlices(u8, "mock_version_1.0", version);

    try std.testing.expectEqual(@as(c_int, 0), try client.processIndex());
    try std.testing.expect(client.devices.len > 0);
    try std.testing.expect(client.memories.len > 0);
}

test "buffer.round_trip" {
    const path = getMockPluginPath();
    var plugin = try runtime.Plugin.init(path);
    defer plugin.deinit();

    var client = try runtime.Client.init(&plugin, std.testing.allocator);
    defer client.deinit();

    const input_data = [_]f32{ 1.5, 2.5, 3.5, 4.5 };
    const dims = [_]i64{4};
    const shape = runtime.Shape{
        .dims = &dims,
        .dtype = .f32,
    };

    var buf = try client.bufferFromHost(f32, &input_data, shape, client.devices[0], null);
    defer buf.deinit();

    try std.testing.expectEqual(@as(usize, 16), try buf.onDeviceSize());
    try std.testing.expect(try buf.isOnCpu());

    const output_data = try buf.toHost(f32, std.testing.allocator);
    defer std.testing.allocator.free(output_data);

    try std.testing.expectEqualSlices(f32, &input_data, output_data);
}

test "buffer.shape_query" {
    const path = getMockPluginPath();
    var plugin = try runtime.Plugin.init(path);
    defer plugin.deinit();

    var client = try runtime.Client.init(&plugin, std.testing.allocator);
    defer client.deinit();

    const input_data = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
    const dims = [_]i64{ 2, 3 };
    const shape = runtime.Shape{
        .dims = &dims,
        .dtype = .f32,
    };

    var buf = try client.bufferFromHost(f32, &input_data, shape, client.devices[0], null);
    defer buf.deinit();

    try std.testing.expectEqualSlices(i64, &dims, buf.shape.dims);
    try std.testing.expectEqual(runtime.DType.f32, buf.shape.dtype);
}

test "exec.compile_and_execute" {
    const path = getMockPluginPath();
    var plugin = try runtime.Plugin.init(path);
    defer plugin.deinit();

    var client = try runtime.Client.init(&plugin, std.testing.allocator);
    defer client.deinit();

    var executable = try client.compile("dummy_stablehlo_bytecode", "stablehlo", "compile_options");
    defer executable.deinit();

    const input_data = [_]f32{ 10.0, 20.0 };
    const dims = [_]i64{2};
    const shape = runtime.Shape{
        .dims = &dims,
        .dtype = .f32,
    };

    var input_buf = try client.bufferFromHost(f32, &input_data, shape, client.devices[0], null);
    defer input_buf.deinit();

    const args = [_]*runtime.Buffer{&input_buf};
    var outputs = try executable.execute(&args, null, std.testing.allocator);
    defer {
        for (outputs) |*out| out.deinit();
        std.testing.allocator.free(outputs);
    }

    try std.testing.expectEqual(@as(usize, 1), outputs.len);
    try std.testing.expectEqualSlices(i64, &dims, outputs[0].shape.dims);
    try std.testing.expectEqual(runtime.DType.f32, outputs[0].shape.dtype);

    const out_data = try outputs[0].toHost(f32, std.testing.allocator);
    defer std.testing.allocator.free(out_data);

    try std.testing.expectEqualSlices(f32, &[_]f32{ 11.0, 21.0 }, out_data);
}
