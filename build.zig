const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // dependency - check build.zig.zon
    const dep_conway_life_c = b.dependency("conway_life_c", .{
        .target = target,
        .optimize = optimize,
    });

    const conway_zig = b.addStaticLibrary(.{
        .name = "conway-zig",
        .root_source_file = .{ .path = "src/conway_life.zig" },
        .target = target,
        .optimize = optimize,
    });

    // add source files from
    conway_zig.addCSourceFiles(.{
        .root = dep_conway_life_c.path(""),
        .files = &.{"conway_life.c"},
    });

    conway_zig.installHeadersDirectory(dep_conway_life_c.path(""), "", .{
        .include_extensions = &.{"conway_life.h"},
    });

    conway_zig.linkLibC();

    // export as a module
    const module = b.addModule("conway_life_c_zig", .{
        .root_source_file = .{ .path = "src/conway_life.zig" },
    });

    // Include header files from btree.c lib
    module.addIncludePath(dep_conway_life_c.path(""));

    //const exe = b.addExecutable(.{
    //.name = "life",
    //.root_source_file = .{ .path = "src/main.zig" },
    //.target = target,
    //.optimize = optimize,
    //});

    //exe.root_module.addImport("conway-zig", module);
    //exe.linkLibrary(conway_zig);
    //b.installArtifact(exe);

    b.installArtifact(conway_zig);

    const conway_zig_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/conway_life.zig" },
        .target = target,
        .optimize = optimize,
    });

    conway_zig_tests.linkLibrary(conway_zig);

    const run_btree_zig_unit_tests = b.addRunArtifact(conway_zig_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_btree_zig_unit_tests.step);
}
