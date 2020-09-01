const std = @import("std");
usingnamespace @import("imgui");

const colors = @import("../colors.zig");
const Tilemap = @import("tilemap.zig").Tilemap;
const Tileset = @import("tileset.zig").Tileset;

pub const TilemapEditor = struct {
    map: Tilemap,
    tileset: Tileset,
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: ImVec2 = .{},

    pub fn init(map: Tilemap, tileset: Tileset) TilemapEditor {
        initColors();
        return .{ .map = map, .tileset = tileset };
    }

    pub fn deinit(self: @This()) void {}

    pub fn mapSize(self: @This()) ImVec2 {
        return .{ .x = @intToFloat(f32, self.map.w * self.tileset.tile_size), .y = @intToFloat(f32, self.map.h * self.tileset.tile_size) };
    }

    pub fn draw(self: @This(), name: [*c]const u8) void {
        // if the alt key is down dont allow scrolling with the mouse wheel since we will be zooming with it
        var window_flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar;
        if (igGetIO().KeyAlt) window_flags |= ImGuiWindowFlags_NoScrollWithMouse;

        defer igEnd();
        if (!igBegin(name, null, window_flags)) return;

        var pos = ogGetCursorScreenPos();
        var map_size = self.mapSize();
        ogAddRectFilled(igGetWindowDrawList(), pos, map_size, colors.rgbToU32(0, 0, 0));

        self.drawPostProcessedMap(pos);

        _ = igInvisibleButton("##input_map_button", map_size);
        const is_hovered = igIsItemHovered(ImGuiHoveredFlags_None);

        if (is_hovered) self.handleInput(pos);
    }

    pub fn drawTileset(self: @This(), name: [*c]const u8) void {
        _ = igBegin(name, null, ImGuiWindowFlags_None);
        igEnd();
    }

    fn handleInput(self: @This(), origin: ImVec2) void {
        // scrolling via drag with alt or super key down
        if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
            var scroll_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0);
            igSetScrollXFloat(igGetScrollX() - scroll_delta.x);
            igSetScrollYFloat(igGetScrollY() - scroll_delta.y);
            igResetMouseDragDelta(ImGuiMouseButton_Left);
            return;
        }
    }

    fn drawPostProcessedMap(self: @This(), origin: ImVec2) void {
        var y: usize = 0;
        while (y < self.map.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.map.w) : (x += 1) {
                const tile = self.map.data[x + y * self.map.w];
                if (tile == 0) continue;

                const offset_x = @intToFloat(f32, x * self.tileset.tile_size);
                const offset_y = @intToFloat(f32, y * self.tileset.tile_size);
                var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
                drawBrush(self.tileset.tile_size, tile - 1, tl);
            }
        }
    }
};



var brushes: [14]ImU32 = undefined;
fn initColors() void {
    brushes = [_]ImU32{
        colors.rgbToU32(189, 63, 110),
        colors.rgbToU32(242, 165, 59),
        colors.rgbToU32(252, 234, 87),
        colors.rgbToU32(103, 223, 84),
        colors.rgbToU32(82, 172, 247),
        colors.rgbToU32(128, 118, 152),
        colors.rgbToU32(237, 127, 166),
        colors.rgbToU32(246, 205, 174),
        colors.rgbToU32(115, 45, 81),
        colors.rgbToU32(58, 131, 85),
        colors.rgbToU32(159, 86, 60),
        colors.rgbToU32(93, 86, 79),
        colors.rgbToU32(193, 194, 198),
        colors.rgbToU32(252, 240, 232),
    };
}

pub fn drawBrush(rect_size: usize, index: usize, tl: ImVec2) void {
    const tile_size = @intToFloat(f32, rect_size);

    // we have 14 unique colors so collapse our index
    const color_index = @mod(index, 14);
    const set = @divTrunc(index, 14);

    ImDrawList_AddQuadFilled(igGetWindowDrawList(), .{ .x = tl.x, .y = tl.y }, .{ .x = tl.x + tile_size, .y = tl.y }, .{ .x = tl.x + tile_size, .y = tl.y + tile_size }, .{ .x = tl.x, .y = tl.y + tile_size }, brushes[color_index]);

    const mini_size = tile_size / 2;
    var pt = tl;
    pt.x += (tile_size - mini_size) / 2;
    pt.y += (tile_size - mini_size) / 2;

    // if (set == 1) {
    //     ImDrawList_AddQuadFilled(igGetWindowDrawList(), .{ .x = pt.x, .y = pt.y }, .{ .x = pt.x + mini_size, .y = pt.y }, .{ .x = pt.x + mini_size, .y = pt.y + mini_size }, .{ .x = pt.x, .y = pt.y + mini_size }, colors.rgbaToU32(0, 0, 0, 100));
    // } else if (set == 2) {
    //     ImDrawList_AddQuad(igGetWindowDrawList(), .{ .x = pt.x, .y = pt.y }, .{ .x = pt.x + mini_size, .y = pt.y }, .{ .x = pt.x + mini_size, .y = pt.y + mini_size }, .{ .x = pt.x, .y = pt.y + mini_size }, colors.rgbaToU32(0, 0, 0, 150), 1);
    // }
}