const std = @import("std");
usingnamespace @import("imgui.zig");
pub const icons = @import("font_awesome.zig");

pub fn ogButton(label: [*c]const u8) bool {
    return igButton(label, .{});
}

pub fn ogImage(texture: ImTextureID, width: i32, height: i32) void {
    const white = ImVec4{ .x = 1, .y = 1, .z = 1, .w = 1 };
    const size = ImVec2{ .x = @intToFloat(f32, width), .y = @intToFloat(f32, height) };
    igImage(texture, size, ImVec2{}, ImVec2{ .x = 1, .y = 1 }, white, ImVec4{});
}

pub fn ogGetCursorScreenPos() ImVec2 {
    var pos = ImVec2{};
    igGetCursorScreenPos(&pos);
    return pos;
}

pub fn ogGetCursorPos() ImVec2 {
    var pos = ImVec2{};
    igGetCursorPos(&pos);
    return pos;
}

pub fn ogGetMouseDragDelta(button: ImGuiMouseButton, lock_threshold: f32) ImVec2 {
    var pos = ImVec2{};
    igGetMouseDragDelta(&pos, button, lock_threshold);
    return pos;
}

/// returns the drag delta of the mouse buttons that is dragging
pub fn ogGetAnyMouseDragDelta() ImVec2 {
    var drag_delta = ImVec2{};
    if (igIsMouseDragging(ImGuiMouseButton_Left, 0)) {
        igGetMouseDragDelta(&drag_delta, ImGuiMouseButton_Left, 0);
    } else {
        igGetMouseDragDelta(&drag_delta, ImGuiMouseButton_Right, 0);
    }
    return drag_delta;
}

/// returns true if any mouse is dragging
pub fn ogIsAnyMouseDragging() bool {
    return igIsMouseDragging(ImGuiMouseButton_Left, 0) or igIsMouseDragging(ImGuiMouseButton_Right, 0);
}

pub fn ogGetContentRegionAvail() ImVec2 {
    var pos = ImVec2{};
    igGetContentRegionAvail(&pos);
    return pos;
}

pub fn ogGetWindowContentRegionMax() ImVec2 {
    var max = ImVec2{};
    igGetWindowContentRegionMax(&max);
    return max;
}

pub fn ogGetItemRectSize() ImVec2 {
    var size = ImVec2{};
    igGetItemRectSize(&size);
    return size;
}

pub fn ogGetWindowCenter() ImVec2 {
    var max = ogGetWindowContentRegionMax();
    max.x /= 2;
    max.y /= 2;
    return max;
}

pub fn ogAddQuad(draw_list: [*c]ImDrawList, tl: ImVec2, size: f32, col: ImU32, thickness: f32) void {
    ImDrawList_AddQuad(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, col, thickness);
}

pub fn ogAddQuadFilled(draw_list: [*c]ImDrawList, tl: ImVec2, size: f32, col: ImU32) void {
    ImDrawList_AddQuadFilled(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, col);
}

/// adds a rect with possibly non-matched width/height to the draw list
pub fn ogAddRectFilled(draw_list: [*c]ImDrawList, tl: ImVec2, size: ImVec2, col: ImU32) void {
    ImDrawList_AddQuadFilled(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size.x, .y = tl.y }, ImVec2{ .x = tl.x + size.x, .y = tl.y + size.y }, ImVec2{ .x = tl.x, .y = tl.y + size.y }, col);
}

pub fn ogInputText(label: [*c]const u8, buf: [*c]u8, buf_size: usize) bool {
    return igInputText(label, buf, buf_size, ImGuiInputTextFlags_None, null, null);
}

/// adds an unformatted (igTextUnformatted) tooltip with a specific wrap width
pub fn ogUnformattedTooltip(text_wrap_pos: f32, text: [*c]const u8) void {
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        igBeginTooltip();
        defer igEndTooltip();

        igPushTextWrapPos(igGetFontSize() * text_wrap_pos);
        igTextUnformatted(text, null);
        igPopTextWrapPos();
    }
}

pub fn ogDrag(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T) bool {
    return ogDragUnsignedFormat(T, label, p_data, v_speed, p_min, p_max, null);
}

pub fn ogDragUnsignedFormat(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T, format: [*c]const u8) bool {
    std.debug.assert(std.meta.trait.isUnsignedInt(T));
    var min = p_min;
    var max = p_max;
    const data_type = switch (T) {
        u8 => ImGuiDataType_U8,
        u16 => ImGuiDataType_U16,
        u32 => ImGuiDataType_U32,
        usize => ImGuiDataType_U64,
        else => unreachable,
    };
    return igDragScalar(label, data_type, p_data, v_speed, &min, &max, format, 1);
}

pub fn ogDragSigned(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T) bool {
    var min = p_min;
    var max = p_max;
    const data_type = switch (T) {
        i16 => ImGuiDataType_S16,
        i32 => ImGuiDataType_S32,
        f32 => ImGuiDataType_Float,
        else => unreachable,
    };
    return igDragScalar(label, data_type, p_data, v_speed, &min, &max, null, 1);
}

pub fn ogColorConvertU32ToFloat4(in: ImU32) ImVec4 {
    var col = ImVec4{};
    igColorConvertU32ToFloat4(&col, in);
    return col;
}
