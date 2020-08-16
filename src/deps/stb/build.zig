const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    exe.linkLibC();
    exe.addIncludeDir("src/deps/stb/src");

    const lib_cflags = &[_][]const u8{"-std=c99"};
    exe.addCSourceFile("src/deps/stb/src/stb_impl.c", lib_cflags);
}
