const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const upaya_build = @import("src/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    var lib_type = b.option(i32, "lib_type", "0: static, 1: dynamic, 2: exe compiled") orelse 0;

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        [_][]const u8{ "tilescript", "tilescript/main.zig" },
        [_][]const u8{ "todo", "examples/todo.zig" },
        [_][]const u8{ "docking", "examples/docking.zig" },
        [_][]const u8{ "empty", "examples/empty.zig" },
    };

    for (examples) |example, i| {
        createExe(b, target, lib_type, example[0], example[1]) catch unreachable;

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) {
            createExe(b, target, lib_type, "run", example[1]) catch unreachable;
        }
    }

    upaya_build.addTests(b, target);
}

/// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: std.build.Target, lib_type: i32, name: []const u8, source: []const u8) !void {
    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("zig-cache/bin");

    upaya_build.linkArtifact(b, exe, target, @intToEnum(upaya_build.LibType, lib_type));

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);
    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
