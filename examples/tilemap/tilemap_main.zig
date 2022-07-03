const std = @import("std");
const upaya = @import("upaya");
const imgui = @import("imgui");
const tilemaps = upaya.tilemaps;
const menu = @import("menu.zig");

var map: tilemaps.Tilemap = undefined;
var map_editor: tilemaps.TilemapEditor = undefined;

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
    map_editor = tilemaps.TilemapEditor.init(tilemaps.Tilemap.init(120, 80), tilemaps.Tileset.init(16));
}

fn shutdown() void {
    map_editor.deinit();
}

fn update() void {
    menu.draw();

    map_editor.draw("Scene");
    map_editor.drawTileset("Palette");
    map_editor.drawLayers("Layers");
}

fn onFileDropped(file: []const u8) void {
    if (std.mem.endsWith(u8, file, ".png")) {
        map_editor.tileset.loadTexture(file);
    }
}

pub fn setupDockLayout(id: imgui.ImGuiID) void {
    var dock_main_id = id;

    // dock_main_id is the left node after this
    const right_id = imgui.igDockBuilderSplitNode(dock_main_id, imgui.ImGuiDir_Right, 0.3, null, &dock_main_id);

    // bottom_right_id is the bottom node after this
    var bottom_right_id: imgui.ImGuiID = 0;
    const top_right_id = imgui.igDockBuilderSplitNode(right_id, imgui.ImGuiDir_Up, 0.5, null, &bottom_right_id);
    imgui.igDockBuilderDockWindow("Layers", top_right_id);
    imgui.igDockBuilderDockWindow("Palette", bottom_right_id);

    // dock_main_id is the bottom node after this
    imgui.igDockBuilderDockWindow("Scene", dock_main_id);

    imgui.igDockBuilderFinish(id);
}
