const std = @import("std");
usingnamespace @import("imgui");
const colors = @import("../colors.zig");
const ts = @import("../tilescript.zig");

const thickness: f32 = 2;

pub fn drawWindow(state: *ts.AppState) void {
        if (igBegin("Brushes", null, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize)) {
            draw(state, 32, false);
        igEnd();
    }
}

pub fn drawPopup(state: *ts.AppState, popup_id: [*c]const u8) void {
    igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{.x = 0.5});
    if (igBeginPopup(popup_id, ImGuiWindowFlags_NoTitleBar)) {
        draw(state, state.map_rect_size, false);
        igEndPopup();
    }
}

/// draws the palette. If skip_input_processing is true, no input processing will occur and the selected brush will not be highlighted.
pub fn draw(state: *ts.AppState, rect_size: f32, skip_input_processing: bool) void {
    const canvas_size = 6 * rect_size;
    const draw_list = igGetWindowDrawList();

    var pos = ogGetCursorScreenPos();
    _ = igInvisibleButton("##but", .{ .x = canvas_size, .y = canvas_size });
    const mouse_pos = igGetIO().MousePos;
    const hovered = igIsItemHovered(ImGuiHoveredFlags_None);

    var y: usize = 0;
    while (y < 6) : (y += 1) {
        var x: usize = 0;
        while (x < 6) : (x += 1) {
            const index = x + y * 6;
            const offset_x = @intToFloat(f32, x) * rect_size;
            const offset_y = @intToFloat(f32, y) * rect_size;
            var tl = ImVec2{ .x = pos.x + offset_x, .y = pos.y + offset_y };

            drawBrush(rect_size, index, tl);

            if (index == state.selected_brush_index and !skip_input_processing) {
                const size = rect_size - thickness;
                tl.x += thickness / 2;
                tl.y += thickness / 2;
                ImDrawList_AddQuad(draw_list, .{ .x = tl.x, .y = tl.y }, .{ .x = tl.x + size, .y = tl.y }, .{ .x = tl.x + size, .y = tl.y + size }, .{ .x = tl.x, .y = tl.y + size }, colors.brush_selected, 2);
            }

            if (hovered and !skip_input_processing) {
                if (tl.x <= mouse_pos.x and mouse_pos.x < tl.x + rect_size and tl.y <= mouse_pos.y and mouse_pos.y < tl.y + rect_size) {
                    if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
                        state.selected_brush_index = index;
                        igCloseCurrentPopup();
                    }
                }
            }
        }
    }
}

pub fn drawBrush(rect_size: f32, index: usize, tl: ImVec2) void {
    // we have 14 unique colors so collapse our index
    const color_index = @mod(index, 14);
    const set = @divTrunc(index, 14);

    ImDrawList_AddQuadFilled(igGetWindowDrawList(), ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + rect_size, .y = tl.y }, ImVec2{ .x = tl.x + rect_size, .y = tl.y + rect_size }, ImVec2{ .x = tl.x, .y = tl.y + rect_size }, colors.brushes[color_index]);

    const mini_size = rect_size / 2;
    var pt = tl;
    pt.x += (rect_size - mini_size) / 2;
    pt.y += (rect_size - mini_size) / 2;

    if (set == 1) {
        ImDrawList_AddQuadFilled(igGetWindowDrawList(), ImVec2{ .x = pt.x, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y + mini_size }, ImVec2{ .x = pt.x, .y = pt.y + mini_size }, colors.colorRgba(0, 0, 0, 100));
    } else if (set == 2) {
        ImDrawList_AddQuad(igGetWindowDrawList(), ImVec2{ .x = pt.x, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y + mini_size }, ImVec2{ .x = pt.x, .y = pt.y + mini_size }, colors.colorRgba(0, 0, 0, 150), 1);
    }
}
