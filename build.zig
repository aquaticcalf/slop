const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("slop", .{
        .root_source_file = b.path("pkg/slop/main.zig"),
        .target = target,
    });

    const jax_mod = b.addModule("jax", .{
        .root_source_file = b.path("pkg/jax/main.zig"),
        .target = target,
    });

    const jax_runtime_mod = b.addModule("runtime", .{
        .root_source_file = b.path("pkg/jax/runtime/main.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "jax", .module = jax_mod },
        },
    });

    const mock_plugin = b.addLibrary(.{
        .name = "mock_pjrt",
        .root_module = b.createModule(.{
            .root_source_file = b.path("pkg/jax/runtime/test/mock.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "jax", .module = jax_mod },
            },
            .link_libc = true,
        }),
        .linkage = .dynamic,
    });
    b.installArtifact(mock_plugin);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("cmd/slop/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "slop", .module = lib_mod },
            .{ .name = "jax", .module = jax_mod },
        },
    });

    const exe = b.addExecutable(.{
        .name = "slop",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.step("run", "run the app");
    const run_artifact = b.addRunArtifact(exe);
    run_cmd.dependOn(&run_artifact.step);
    run_artifact.step.dependOn(b.getInstallStep());
    run_artifact.addPassthruArgs();

    const lib_test_mod = b.createModule(.{
        .root_source_file = b.path("pkg/slop/test/main.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "slop", .module = lib_mod },
            .{ .name = "jax", .module = jax_mod },
        },
    });

    const jax_runtime_test_mod = b.createModule(.{
        .root_source_file = b.path("pkg/jax/runtime/test/main.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "jax", .module = jax_mod },
            .{ .name = "runtime", .module = jax_runtime_mod },
        },
    });

    const exe_test_mod = b.createModule(.{
        .root_source_file = b.path("cmd/slop/test/main.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "slop", .module = lib_mod },
            .{ .name = "jax", .module = jax_mod },
        },
    });

    const test_step = b.step("test", "run tests");
    test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = lib_test_mod })).step);

    const jax_runtime_test = b.addTest(.{ .root_module = jax_runtime_test_mod });
    const run_jax_runtime_test = b.addRunArtifact(jax_runtime_test);
    run_jax_runtime_test.step.dependOn(&b.addInstallArtifact(mock_plugin, .{}).step);
    test_step.dependOn(&run_jax_runtime_test.step);

    test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = exe_test_mod })).step);
}
