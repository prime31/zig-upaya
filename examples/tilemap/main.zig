const std = @import("std");
const upaya = @import("upaya");
usingnamespace @import("imgui");
usingnamespace upaya.tilemaps;
const menu = @import("menu.zig");

var map: Tilemap = undefined;
var map_editor: TilemapEditor = undefined;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .shutdown = shutdown,
        .setupDockLayout = setupDockLayout,
        .window_title = "Upaya Tile Edit",
        .onFileDropped = onFileDropped,
    });
}

fn init() void {
    const tileset = Tileset.init(16);
    map_editor = TilemapEditor.init(Tilemap.init(120, 80), tileset);
}

fn shutdown() void {
    map_editor.deinit();
}

fn update() void {
    menu.draw();

    map_editor.draw("Scene");
    map_editor.drawTileset("Palette");

    _ = igBegin("Layers", null, ImGuiWindowFlags_None);
    igEnd();
}

fn onFileDropped(file: []const u8) void {}

pub fn setupDockLayout(id: ImGuiID) void {
    var dock_main_id = id;

    // dock_main_id is the left node after this
    const right_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Right, 0.3, null, &dock_main_id);

    // bottom_right_id is the bottom node after this
    var bottom_right_id: ImGuiID = 0;
    const top_right_id = igDockBuilderSplitNode(right_id, ImGuiDir_Up, 0.5, null, &bottom_right_id);
    igDockBuilderDockWindow("Layers", top_right_id);
    igDockBuilderDockWindow("Palette", bottom_right_id);

    // dock_main_id is the bottom node after this
    igDockBuilderDockWindow("Scene", dock_main_id);

    igDockBuilderFinish(id);
}
