const std = @import("std");
const imgui = @import("imgui");

const colors = @import("../colors.zig");
const Tilemap = @import("tilemap.zig").Tilemap;
const Tileset = @import("tileset.zig").Tileset;

pub const TilemapEditor = struct {
    map: Tilemap,
    tileset: Tileset,
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: imgui.ImVec2 = .{},

    pub fn init(map: Tilemap, tileset: Tileset) TilemapEditor {
        return .{ .map = map, .tileset = tileset };
    }

    pub fn deinit(_: @This()) void {}

    pub fn mapSize(self: @This()) imgui.ImVec2 {
        return .{ .x = @intToFloat(f32, self.map.w * self.tileset.tile_size), .y = @intToFloat(f32, self.map.h * self.tileset.tile_size) };
    }

    pub fn draw(self: *@This(), name: [*c]const u8) void {
        // if the alt key is down dont allow scrolling with the mouse wheel since we will be zooming with it
        var window_flags = imgui.ImGuiWindowFlags_NoCollapse | imgui.ImGuiWindowFlags_AlwaysHorizontalScrollbar;
        if (imgui.igGetIO().KeyAlt) window_flags |= imgui.ImGuiWindowFlags_NoScrollWithMouse;

        defer imgui.igEnd();
        if (!imgui.igBegin(name, null, window_flags)) return;

        var pos = imgui.ogGetCursorScreenPos();
        var map_size = self.mapSize();
        imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), pos, map_size, colors.rgbToU32(0, 0, 0));

        self.drawPostProcessedMap(pos);

        _ = imgui.ogInvisibleButton("##input_map_button", map_size, imgui.ImGuiButtonFlags_None);
        const is_hovered = imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None);
        if (is_hovered) self.handleInput(pos);

        // draw a rect over the current tile
        if (is_hovered and !self.shift_dragged) {
            var tile = tileIndexUnderPos(imgui.igGetIO().MousePos, self.tileset.tile_size, pos);
            const tl = imgui.ImVec2{ .x = pos.x + @intToFloat(f32, tile.x * self.tileset.tile_size), .y = pos.y + @intToFloat(f32, tile.y * self.tileset.tile_size) };
            imgui.ogAddQuad(imgui.igGetWindowDrawList(), tl, @intToFloat(f32, self.tileset.tile_size), colors.rgbToU32(116, 252, 253), 1);
        }
    }

    pub fn drawTileset(self: *@This(), name: [*c]const u8) void {
        self.tileset.drawTileset(name);
    }

    pub fn drawLayers(self: *@This(), name: [*c]const u8) void {
        defer imgui.igEnd();
        if (!imgui.igBegin(name, null, imgui.ImGuiWindowFlags_None)) return;

        for (self.map.layers) |layer, i| {
            imgui.igPushIDInt(@intCast(c_int, i));
            defer imgui.igPopID();

            if (imgui.ogSelectableBool(layer.name.ptr, i == self.map.current_layer, imgui.ImGuiSelectableFlags_None, .{})) {
                self.map.current_layer = i;
            }
        }

        if (imgui.ogButton("Add Layer")) self.map.addLayer();
    }

    fn handleInput(self: *@This(), origin: imgui.ImVec2) void {
        // scrolling via drag with alt or super key down
        if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0) and (imgui.igGetIO().KeyAlt or imgui.igGetIO().KeySuper)) {
            var scroll_delta = imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Left, 0);
            imgui.igSetScrollXFloat(imgui.igGetScrollX() - scroll_delta.x);
            imgui.igSetScrollYFloat(imgui.igGetScrollY() - scroll_delta.y);
            imgui.igResetMouseDragDelta(imgui.ImGuiMouseButton_Left);
            return;
        }

        // box selection with left/right mouse + shift
        if (imgui.ogIsAnyMouseDragging() and imgui.igGetIO().KeyShift) {
            var drag_delta = imgui.ogGetAnyMouseDragDelta();

            var tile1 = tileIndexUnderPos(imgui.igGetIO().MousePos, self.tileset.tile_size, origin);
            drag_delta = drag_delta.add(origin);
            var tile2 = tileIndexUnderPos(imgui.igGetIO().MousePos, self.tileset.tile_size, drag_delta);

            const tile_size = @intToFloat(f32, self.tileset.tile_size);
            const min_x = @intToFloat(f32, std.math.min(tile1.x, tile2.x)) * tile_size + origin.x;
            const min_y = @intToFloat(f32, std.math.max(tile1.y, tile2.y)) * tile_size + tile_size + origin.y;
            const max_x = @intToFloat(f32, std.math.max(tile1.x, tile2.x)) * tile_size + tile_size + origin.x;
            const max_y = @intToFloat(f32, std.math.min(tile1.y, tile2.y)) * tile_size + origin.y;

            const color = if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0)) colors.rgbToU32(255, 255, 255) else colors.rgbToU32(220, 0, 0);
            imgui.ogImDrawList_AddQuad(imgui.igGetWindowDrawList(), &imgui.ImVec2{ .x = min_x, .y = max_y }, &imgui.ImVec2{ .x = max_x, .y = max_y }, &imgui.ImVec2{ .x = max_x, .y = min_y }, &imgui.ImVec2{ .x = min_x, .y = min_y }, color, 2);

            self.shift_dragged = true;
        } else if ((imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left) or imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Right)) and self.shift_dragged) {
            self.shift_dragged = false;

            var drag_delta = if (imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left)) imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Left, 0) else imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Right, 0);
            var tile1 = tileIndexUnderPos(imgui.igGetIO().MousePos, self.tileset.tile_size, origin);
            drag_delta = drag_delta.add(origin);
            var tile2 = tileIndexUnderPos(imgui.igGetIO().MousePos, self.tileset.tile_size, drag_delta);

            const min_x = std.math.min(tile1.x, tile2.x);
            var min_y = std.math.min(tile1.y, tile2.y);
            const max_x = std.math.max(tile1.x, tile2.x);
            const max_y = std.math.max(tile1.y, tile2.y);

            // either set the tile to a brush or 0 depending on mouse button
            const selected_brush_index: usize = self.tileset.selected; // TODO: brushes
            const tile_value = if (imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left)) selected_brush_index + 1 else 0;
            while (min_y <= max_y) : (min_y += 1) {
                var x = min_x;
                while (x <= max_x) : (x += 1) {
                    self.map.setTile(x, min_y, @intCast(u8, tile_value));
                }
            }
        } else if (imgui.ogIsAnyMouseDown() and !imgui.igGetIO().KeyShift) {
            var tile = tileIndexUnderPos(imgui.igGetIO().MousePos, self.tileset.tile_size, origin);

            const brush_index: u8 = if (imgui.igIsMouseDown(imgui.ImGuiMouseButton_Left)) self.tileset.selected + 1 else 0;
            // if the mouse down last frame, get last mouse pos and ensure we dont skip tiles when drawing
            if (self.dragged) {
                self.commitInBetweenTiles(tile.x, tile.y, origin, brush_index);
            }
            self.dragged = true;
            self.prev_mouse_pos = imgui.igGetIO().MousePos;
            self.map.setTile(tile.x, tile.y, brush_index);
        } else if (imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left) or imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Right)) {
            self.dragged = false;
        }
    }

    fn drawPostProcessedMap(self: @This(), origin: imgui.ImVec2) void {
        for (self.map.layers) |layer| {
            var y: usize = 0;
            while (y < self.map.h) : (y += 1) {
                var x: usize = 0;
                while (x < self.map.w) : (x += 1) {
                    const tile = layer.data[x + y * self.map.w];
                    if (tile == 0) continue;

                    const offset = imgui.ImVec2.init(@intToFloat(f32, x * self.tileset.tile_size), @intToFloat(f32, y * self.tileset.tile_size));
                    var tl = origin.add(offset);
                    self.drawTile(tl, tile - 1, 1);
                }
            }
        }
    }

    fn commitInBetweenTiles(self: *@This(), tile_x: usize, tile_y: usize, origin: imgui.ImVec2, color: u8) void {
        var prev_tile = tileIndexUnderPos(self.prev_mouse_pos, self.tileset.tile_size, origin);
        const abs_x = std.math.absInt(@intCast(i32, tile_x) - @intCast(i32, prev_tile.x)) catch unreachable;
        const abs_y = std.math.absInt(@intCast(i32, tile_y) - @intCast(i32, prev_tile.y)) catch unreachable;
        if (abs_x <= 1 and abs_y <= 1) {
            return;
        }

        self.bresenham(@intToFloat(f32, prev_tile.x), @intToFloat(f32, prev_tile.y), @intToFloat(f32, tile_x), @intToFloat(f32, tile_y), color);
    }

    /// fill in all the tiles between the two mouse positions using bresenham's line algo
    fn bresenham(self: *@This(), in_x1: f32, in_y1: f32, in_x2: f32, in_y2: f32, color: u8) void {
        var x1 = in_x1;
        var y1 = in_y1;
        var x2 = in_x2;
        var y2 = in_y2;

        const steep = @fabs(y2 - y1) > @fabs(x2 - x1);
        if (steep) {
            std.mem.swap(f32, &x1, &y1);
            std.mem.swap(f32, &x2, &y2);
        }

        if (x1 > x2) {
            std.mem.swap(f32, &x1, &x2);
            std.mem.swap(f32, &y1, &y2);
        }

        const dx: f32 = x2 - x1;
        const dy: f32 = @fabs(y2 - y1);

        var err: f32 = dx / 2.0;
        var ystep: i32 = if (y1 < y2) 1 else -1;
        var y: i32 = @floatToInt(i32, y1);

        const maxX: i32 = @floatToInt(i32, x2);

        var x: i32 = @floatToInt(i32, x1);
        while (x <= maxX) : (x += 1) {
            if (steep) {
                self.map.setTile(@intCast(usize, y), @intCast(usize, x), color);
            } else {
                self.map.setTile(@intCast(usize, x), @intCast(usize, y), color);
            }

            err -= dy;
            if (err < 0) {
                y += ystep;
                err += dx;
            }
        }
    }

    fn drawTile(self: @This(), tl: imgui.ImVec2, tile: usize, zoom: usize) void {
        var br = tl;
        br.x += @intToFloat(f32, self.tileset.tile_size * zoom);
        br.y += @intToFloat(f32, self.tileset.tile_size * zoom);

        const rect = self.tileset.uvsForTile(tile);
        const uv0 = imgui.ImVec2{ .x = rect.x, .y = rect.y };
        const uv1 = imgui.ImVec2{ .x = rect.x + rect.w, .y = rect.y + rect.h };

        imgui.ImDrawList_AddImage(imgui.igGetWindowDrawList(), self.tileset.tex.imTextureID(), tl, br, uv0, uv1, 0xffffffff);
    }
};

/// helper to find the tile under the position given a top-left position of the grid (origin) and a grid size
pub fn tileIndexUnderPos(pos: imgui.ImVec2, rect_size: usize, origin: imgui.ImVec2) struct { x: usize, y: usize } {
    const final_pos = pos.subtract(origin);
    return .{ .x = @divTrunc(@floatToInt(usize, final_pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, final_pos.y), rect_size) };
}
