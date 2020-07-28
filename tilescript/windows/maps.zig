const std = @import("std");
usingnamespace @import("imgui");
const colors = @import("../colors.zig");
const history = @import("../history.zig");
const ts = @import("../tilescript.zig");

// helper to maintain state during a drag selection
var shift_dragged = false;
var dragged = false;
var prev_mouse_pos: ImVec2 = undefined;

pub fn drawWindows(state: *ts.AppState) void {
    // if the alt key is dont dont allow scrolling with the mouse since we will be zooming
    var window_flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar;
    if (igGetIO().KeyAlt) window_flags |= ImGuiWindowFlags_NoScrollWithMouse;

    if (igBegin("Input Map", null, window_flags)) {
        draw(state, true);
    }
    igEnd();

    if (state.prefs.windows.post_processed_map) {
        if (igBegin("Post Processed Map", &state.prefs.windows.post_processed_map, window_flags)) {
            draw(state, false);
        }
        igEnd();
    }
}

fn draw(state: *ts.AppState, input_map: bool) void {
    var pos = ogGetCursorScreenPos();

    const map_size = state.mapSize();
    ogAddRectFilled(igGetWindowDrawList(), pos, map_size, colors.colorRgb(0, 0, 0));

    _ = igInvisibleButton("##input_map_button", map_size);
    const is_hovered = igIsItemHovered(ImGuiHoveredFlags_None);

    if (input_map) {
        drawInputMap(state, pos);
    } else {
        drawPostProcessedMap(state, pos);
    }

    if (is_hovered) {
        handleInput(state, pos, input_map);
    } else if (input_map) {
        // only set dragged to false if we are drawing the input_map since it is the one that accepts input
        dragged = false;
    }

    // draw a rect over the current tile
    if (is_hovered and !shift_dragged) {
        var tile = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), pos);
        const tl = ImVec2{ .x = pos.x + @intToFloat(f32, tile.x) * state.map_rect_size, .y = pos.y + @intToFloat(f32, tile.y) * state.map_rect_size };
        ogAddQuad(igGetWindowDrawList(), tl, state.map_rect_size, colors.rule_result_selected_outline, 1);
    }
}

fn drawInputMap(state: *ts.AppState, origin: ImVec2) void {
    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            const tile = state.map.data[x + y * state.map.w];
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            ts.drawBrush(state.map_rect_size, tile - 1, tl);
        }
    }
}

fn drawPostProcessedMap(state: *ts.AppState, origin: ImVec2) void {
    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            const tile = state.processed_map_data[x + y * state.map.w];
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            ts.drawBrush(state.map_rect_size, tile - 1, tl);
        }
    }
}

fn handleInput(state: *ts.AppState, origin: ImVec2, input_map: bool) void {
    // scrolling via drag with alt or super key down
    if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
        var scroll_delta = ImVec2{};
        igGetMouseDragDelta(&scroll_delta, 0, 0);

        igSetScrollXFloat(igGetScrollX() - scroll_delta.x);
        igSetScrollYFloat(igGetScrollY() - scroll_delta.y);
        igResetMouseDragDelta(ImGuiMouseButton_Left);

        syncScrollPosition(state, input_map);

        return;
    }

    // zoom with alt + mouse wheel
    if (igGetIO().KeyAlt and igGetIO().MouseWheel != 0) {
        if (igGetIO().MouseWheel > 0) {
            if (state.prefs.tile_size_multiplier > 1) {
                state.prefs.tile_size_multiplier -= 1;
            }
        } else if (state.prefs.tile_size_multiplier < 4) {
            state.prefs.tile_size_multiplier += 1;
        }

        state.map_rect_size = @intToFloat(f32, state.map.tile_size * state.prefs.tile_size_multiplier);
        igGetIO().MouseWheel = 0;
        return;
    }

    if (igGetIO().MouseWheel != 0 or igGetIO().MouseWheelH != 0) {
        syncScrollPosition(state, input_map);
    }

    if (state.object_edit_mode) {
        return;
    }

    // box selection with left/right mouse + shift
    if (ogIsAnyMouseDragging() and igGetIO().KeyShift) {
        var drag_delta = ogGetAnyMouseDragDelta();

        var tile1 = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), origin);
        drag_delta.x += origin.x;
        drag_delta.y += origin.y;
        var tile2 = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), drag_delta);

        const min_x = @intToFloat(f32, std.math.min(tile1.x, tile2.x)) * state.map_rect_size + origin.x;
        const min_y = @intToFloat(f32, std.math.max(tile1.y, tile2.y)) * state.map_rect_size + state.map_rect_size + origin.y;
        const max_x = @intToFloat(f32, std.math.max(tile1.x, tile2.x)) * state.map_rect_size + state.map_rect_size + origin.x;
        const max_y = @intToFloat(f32, std.math.min(tile1.y, tile2.y)) * state.map_rect_size + origin.y;

        const color = if (igIsMouseDragging(ImGuiMouseButton_Left, 0)) colors.colorRgb(255, 255, 255) else colors.colorRgb(220, 0, 0);
        ImDrawList_AddQuad(igGetWindowDrawList(), .{ .x = min_x, .y = max_y }, .{ .x = max_x, .y = max_y }, .{ .x = max_x, .y = min_y }, .{ .x = min_x, .y = min_y }, color, 2);

        shift_dragged = true;
    } else if ((igIsMouseReleased(ImGuiMouseButton_Left) or igIsMouseReleased(ImGuiMouseButton_Right)) and shift_dragged) {
        shift_dragged = false;

        var drag_delta = if (igIsMouseReleased(ImGuiMouseButton_Left)) ogGetMouseDragDelta(ImGuiMouseButton_Left, 0) else ogGetMouseDragDelta(ImGuiMouseButton_Right, 0);
        var tile1 = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), origin);
        drag_delta.x += origin.x;
        drag_delta.y += origin.y;
        var tile2 = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), drag_delta);

        const min_x = std.math.min(tile1.x, tile2.x);
        var min_y = std.math.min(tile1.y, tile2.y);
        const max_x = std.math.max(tile1.x, tile2.x);
        const max_y = std.math.max(tile1.y, tile2.y);

        // undo support
        const start_index = min_x + min_y * state.map.w;
        const end_index = max_x + max_y * state.map.w;
        history.push(state.map.data[start_index .. end_index + 1]);

        // either set the tile to a brush or 0 depending on mouse button
        const tile_value = if (igIsMouseReleased(ImGuiMouseButton_Left)) state.selected_brush_index + 1 else 0;
        while (min_y <= max_y) : (min_y += 1) {
            var x = min_x;
            while (x <= max_x) : (x += 1) {
                state.map.setTile(x, min_y, @intCast(u8, tile_value));
            }
        }
        history.commit();
        state.map_data_dirty = true;
    } else if (igIsMouseDown(ImGuiMouseButton_Left) and !igGetIO().KeyShift) {
        var tile = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), origin);

        // if the mouse down last frame, get last mouse pos and ensure we dont skip tiles when drawing
        if (dragged) {
            commitInBetweenTiles(state, tile.x, tile.y, origin, @intCast(u8, state.selected_brush_index + 1));
        }
        dragged = true;
        prev_mouse_pos = igGetIO().MousePos;

        const index = tile.x + tile.y * state.map.w;
        history.push(state.map.data[index .. index + 1]);
        state.map.setTile(tile.x, tile.y, @intCast(u8, state.selected_brush_index + 1));
        state.map_data_dirty = true;
    } else if (igIsMouseDown(ImGuiMouseButton_Right)) {
        var tile = ts.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), origin);

        // if the mouse down last frame, get last mouse pos and ensure we dont skip tiles when drawing
        if (dragged) {
            commitInBetweenTiles(state, tile.x, tile.y, origin, 0);
        }
        dragged = true;
        prev_mouse_pos = igGetIO().MousePos;

        const index = tile.x + tile.y * state.map.w;
        history.push(state.map.data[index .. index + 1]);
        state.map.setTile(tile.x, tile.y, 0);
        state.map_data_dirty = true;
    } else if (igIsMouseReleased(ImGuiMouseButton_Left) or igIsMouseReleased(ImGuiMouseButton_Right)) {
        dragged = false;
        history.commit();
    }
}

/// syncs the scroll position between the input map, post processed map and output maps
fn syncScrollPosition(state: *ts.AppState, input_map: bool) void {
    const new_scroll_x = igGetScrollX();
    const new_scroll_y = igGetScrollY();

    // sync scroll position with the opposite map window if it is visible
    var needs_sync = (input_map and state.prefs.windows.post_processed_map) or !input_map;
    if (needs_sync) {
        _ = igBegin(if (input_map) "Post Processed Map" else "Input Map", &needs_sync, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar);
        igSetScrollXFloat(new_scroll_x);
        igSetScrollYFloat(new_scroll_y);
        igEnd();
    }

    if (igBegin("Output Map", null, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
        igSetScrollXFloat(new_scroll_x);
        igSetScrollYFloat(new_scroll_y);
    }
    igEnd();
}

fn commitInBetweenTiles(state: *ts.AppState, tile_x: usize, tile_y: usize, origin: ImVec2, color: u8) void {
    var prev_tile = ts.tileIndexUnderPos(prev_mouse_pos, @floatToInt(usize, state.map_rect_size), origin);
    const abs_x = std.math.absInt(@intCast(i32, tile_x) - @intCast(i32, prev_tile.x)) catch unreachable;
    const abs_y = std.math.absInt(@intCast(i32, tile_y) - @intCast(i32, prev_tile.y)) catch unreachable;
    if (abs_x <= 1 and abs_y <= 1) {
        return;
    }

    bresenham(state, @intToFloat(f32, prev_tile.x), @intToFloat(f32, prev_tile.y), @intToFloat(f32, tile_x), @intToFloat(f32, tile_y), color);
}

/// fill in all the tiles between the two mouse positions using bresenham's line algo
fn bresenham(state: *ts.AppState, in_x1: f32, in_y1: f32, in_x2: f32, in_y2: f32, color: u8) void {
    var x1 = in_x1;
    var y1 = in_y1;
    var x2 = in_x2;
    var y2 = in_y2;

    const steep = std.math.absFloat(y2 - y1) > std.math.absFloat(x2 - x1);
    if (steep) {
        std.mem.swap(f32, &x1, &y1);
        std.mem.swap(f32, &x2, &y2);
    }

    if (x1 > x2) {
        std.mem.swap(f32, &x1, &x2);
        std.mem.swap(f32, &y1, &y2);
    }

    const dx: f32 = x2 - x1;
    const dy: f32 = std.math.absFloat(y2 - y1);

    var err: f32 = dx / 2.0;
    var ystep: i32 = if (y1 < y2) 1 else -1;
    var y: i32 = @floatToInt(i32, y1);

    const maxX: i32 = @floatToInt(i32, x2);

    var x: i32 = @floatToInt(i32, x1);
    while (x <= maxX) : (x += 1) {
        if (steep) {
            const index = @intCast(usize, y) + @intCast(usize, x) * state.map.w;
            history.push(state.map.data[index .. index + 1]);
            state.map.setTile(@intCast(usize, y), @intCast(usize, x), color);
        } else {
            const index = @intCast(usize, x) + @intCast(usize, y) * state.map.w;
            history.push(state.map.data[index .. index + 1]);
            state.map.setTile(@intCast(usize, x), @intCast(usize, y), color);
        }

        err -= dy;
        if (err < 0) {
            y += ystep;
            err += dx;
        }
    }
}
