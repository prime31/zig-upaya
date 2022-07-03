const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const Color = math.Color;
usingnamespace @import("windows/windows.zig");
const imgui = @import("imgui");

const Editor = @import("editor.zig").Editor;

var editor: Editor = undefined;

var tex: upaya.Texture = undefined;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .shutdown = shutdown,
        .setupDockLayout = Editor.setupDockLayout,
        .window_title = "Upaya Edit",
        .onFileDropped = onFileDropped,
    });
}

fn init() void {
    editor = Editor.init();
}

fn shutdown() void {
    editor.deinit();
}

fn update() void {
    editor.update();
}

fn onFileDropped(file: []const u8) void {
    editor.handleDroppedFile(file);
}