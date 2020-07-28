const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const sokol_build = @import("deps/sokol/build.zig");
const stb_image_build = @import("deps/stb_image/build.zig");
const imgui_build = @import("deps/imgui/build.zig");
const filebrowser_build = @import("deps/filebrowser/build.zig");

pub const LibType = enum(i32) {
    static,
    dynamic, // requires DYLD_LIBRARY_PATH to point to the dylib path
    exe_compiled,
};

pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target, lib_type: LibType) void {
    sokol_build.linkArtifact(b, artifact, target);
    stb_image_build.linkArtifact(b, artifact, target, @intToEnum(stb_image_build.LibType, @enumToInt(lib_type)));
    imgui_build.linkArtifact(b, artifact, target);
    filebrowser_build.linkArtifact(b, artifact, target, @intToEnum(filebrowser_build.LibType, @enumToInt(lib_type)));

    const sokol = Pkg{
        .name = "sokol",
        .path = "src/deps/sokol/sokol.zig",
    };
    const stb_image = Pkg{
        .name = "stb_image",
        .path = "src/deps/stb_image/stb_image.zig",
    };
    const imgui = Pkg{
        .name = "imgui",
        .path = "src/deps/imgui/imgui.zig",
    };
    const filebrowser = Pkg{
        .name = "filebrowser",
        .path = "src/deps/filebrowser/filebrowser.zig",
    };
    const upaya = Pkg{
        .name = "upaya",
        .path = "src/upaya.zig",
        .dependencies = &[_]Pkg{stb_image, filebrowser, sokol, imgui},
    };

    // packages exported to userland
    artifact.addPackage(upaya);
    artifact.addPackage(sokol);
    artifact.addPackage(stb_image);
    artifact.addPackage(imgui);
    artifact.addPackage(filebrowser);
}

// add tests.zig file runnable via "zig build test"
pub fn addTests(b: *Builder, target: std.build.Target) void {
    var tst = b.addTest("src/tests.zig");
    linkArtifact(b, tst, target, .exe_compiled);
    const test_step = b.step("test", "Run tests in tests.zig");
    test_step.dependOn(&tst.step);
}
