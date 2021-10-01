const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zls", "src/main.zig");
    const exe_options = b.addOptions();
    exe.addOptions("build_options", exe_options);

    exe_options.addOption(
        []const u8,
        "data_version",
        b.option([]const u8, "data_version", "The Zig version your compiler is.") orelse "master",
    );

    exe.addPackage(.{ .name = "known-folders", .path = .{ .path = "src/known-folders/known-folders.zig" } });
    exe.addPackage(.{ .name = "zinput", .path = .{ .path = "src/zinput/src/main.zig" } });

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    b.installFile("src/special/build_runner.zig", "bin/build_runner.zig");

    const test_step = b.step("test", "Run all the tests");
    test_step.dependOn(b.getInstallStep());

    var unit_tests = b.addTest("src/unit_tests.zig");
    unit_tests.setBuildMode(.Debug);
    test_step.dependOn(&unit_tests.step);

    var session_tests = b.addTest("tests/sessions.zig");
    session_tests.addPackage(.{ .name = "header", .path = .{ .path = "src/header.zig" } });
    session_tests.setBuildMode(.Debug);
    test_step.dependOn(&session_tests.step);
}
