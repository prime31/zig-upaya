const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

/// test builder. This build file is meant to be included in an executable project. This build method is here
/// only for local testing.
pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType) void {
    switch (lib_type) {
        .static => {
            const lib = b.addStaticLibrary("FileBrowser", null);
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileFontStash(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .dynamic => {
            const lib = b.addSharedLibrary("FileBrowser", null, b.version(0, 0, 1));
            lib.setBuildMode(builtin.Mode.ReleaseSmall);
            lib.setTarget(target);

            compileFontStash(b, lib, target);
            lib.install();

            artifact.linkLibrary(lib);
        },
        .exe_compiled => {
            compileFontStash(b, artifact, target);
        },
    }
}

fn compileFontStash(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
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
