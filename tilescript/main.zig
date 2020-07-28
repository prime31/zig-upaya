const std = @import("std");
const upaya = @import("upaya");
usingnamespace upaya.imgui;
const TileScript = @import("tilescript.zig").TileScript;

var ts: TileScript = undefined;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .setupDockLayout = TileScript.setupDockLayout,
        .shutdown = shutdown,
        .width = 1024,
        .height = 768,
        .window_title = "TileScript",
        .onFileDropped = onFileDropped,
    });
}

fn init() void {
    ts = TileScript.init();
}

fn update() void {
    ts.draw();
}

fn shutdown() void {
    ts.state.savePrefs();
    ts.deinit();
}

fn onFileDropped(file: []const u8) void {
    ts.handleDroppedFile(file);
}
