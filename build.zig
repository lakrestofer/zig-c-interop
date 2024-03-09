const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // build options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // build C library
    const c_lib = b.addStaticLibrary(.{ .name = "cdep", .target = target, .optimize = optimize, .link_libc = true });
    c_lib.addIncludePath(.{ .path = "include/" });
    c_lib.linkLibC();
    c_lib.addCSourceFiles(.{
        .files = &.{"src/cdep/cxmath.c"},
        .flags = &.{
            "-pedantic",
            "-Wall",
            "-Wno-missing-field-initializers",
        },
    });
    b.installArtifact(c_lib);

    // build exe
    const exe = b.addExecutable(.{
        .name = "zig-c-interop",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.linkLibrary(c_lib);
    exe.addIncludePath(.{ .path = "include/" });
    b.installArtifact(exe);

    // build tests
    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // == run command ==
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // == define steps ==
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
