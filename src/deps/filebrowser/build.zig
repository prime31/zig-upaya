const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

/// test builder. This build file is meant to be included in an executable project. This build method is here
/// only for local testing.
pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

pub fn linkArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    if (target.isWindows()) {
        exe.linkSystemLibrary("comdlg32");
        exe.linkSystemLibrary("ole32");
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("shell32");
        exe.linkSystemLibrary("c");
    }
    exe.linkLibC();

    const lib_cflags = &[_][]const u8{ "-D_CRT_SECURE_NO_WARNINGS", "-D_CRT_SECURE_NO_DEPRECATE" };
    exe.addCSourceFile("src/deps/filebrowser/src/tinyfiledialogs.c", lib_cflags);
}
