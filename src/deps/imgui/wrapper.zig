const std = @import("std");
const imgui = @import("imgui.zig");
pub const icons = @import("font_awesome.zig");

extern fn _ogImage(user_texture_id: imgui.ImTextureID, size: *const imgui.ImVec2, uv0: *const imgui.ImVec2, uv1: *const imgui.ImVec2) void;
extern fn _ogImageButton(user_texture_id: imgui.ImTextureID, size: *const imgui.ImVec2, uv0: *const imgui.ImVec2, uv1: *const imgui.ImVec2, frame_padding: c_int) bool;
extern fn _ogColoredText(r: f32, g: f32, b: f32, text: [*c]const u8) void;

// arm64 cant send imgui.ImVec2s to anything...
extern fn _ogButton(label: [*c]const u8, x: f32, y: f32) bool;
extern fn _ogImDrawData_ScaleClipRects(self: [*c]imgui.ImDrawData, fb_scale: f32) void;
extern fn _ogDockBuilderSetNodeSize(node_id: imgui.ImGuiID, size: *const imgui.ImVec2) void;
extern fn _ogSetNextWindowPos(pos: *const imgui.ImVec2, cond: imgui.ImGuiCond, pivot: *const imgui.ImVec2) void;
extern fn _ogSetNextWindowSize(size: *const imgui.ImVec2, cond: imgui.ImGuiCond) void;
extern fn _ogPushStyleVarVec2(idx: imgui.ImGuiStyleVar, w: f32, y: f32) void;
extern fn _ogInvisibleButton(str_id: [*c]const u8, w: f32, h: f32, flags: imgui.ImGuiButtonFlags) bool;
extern fn _ogSelectableBool(label: [*c]const u8, selected: bool, flags: imgui.ImGuiSelectableFlags, w: f32, h: f32) bool;
extern fn _ogDummy(w: f32, h: f32) void;
extern fn _ogBeginChildFrame(id: imgui.ImGuiID, w: f32, h: f32, flags: imgui.ImGuiWindowFlags) bool;
extern fn _ogBeginChildEx(name: [*c]const u8, id: imgui.ImGuiID, size_arg: *const imgui.ImVec2, border: bool, flags: imgui.ImGuiWindowFlags) bool;
extern fn _ogDockSpace(id: imgui.ImGuiID, w: f32, h: f32, flags: imgui.ImGuiDockNodeFlags, window_class: [*c]const imgui.ImGuiWindowClass) void;
extern fn _ogImDrawList_AddQuad(self: [*c]imgui.ImDrawList, p1: *const imgui.ImVec2, p2: *const imgui.ImVec2, p3: *const imgui.ImVec2, p4: *const imgui.ImVec2, col: imgui.ImU32, thickness: f32) void;
extern fn _ogImDrawList_AddQuadFilled(self: [*c]imgui.ImDrawList, p1: *const imgui.ImVec2, p2: *const imgui.ImVec2, p3: *const imgui.ImVec2, p4: *const imgui.ImVec2, col: imgui.ImU32) void;
extern fn _ogImDrawList_AddImage(self: [*c]imgui.ImDrawList, id: imgui.ImTextureID, p_min: *const imgui.ImVec2, p_max: *const imgui.ImVec2, uv_min: *const imgui.ImVec2, uv_max: *const imgui.ImVec2, col: imgui.ImU32) void;
extern fn _ogImDrawList_AddLine(self: [*c]imgui.ImDrawList, p1: *const imgui.ImVec2, p2: *const imgui.ImVec2, col: imgui.ImU32, thickness: f32) void;
extern fn _ogSetCursorScreenPos(pos: *const imgui.ImVec2) void;
extern fn _ogListBoxHeaderVec2(label: [*c]const u8, size: *const imgui.ImVec2) bool;
extern fn _ogColorConvertFloat4ToU32(color: *const imgui.ImVec4) imgui.ImU32;

// implementations for ABI incompatibility bugs
pub fn ogImage(texture: imgui.ImTextureID, width: i32, height: i32) void {
    var size = imgui.ImVec2{ .x = @intToFloat(f32, width), .y = @intToFloat(f32, height) };
    _ogImage(texture, &size, &imgui.ImVec2{}, &imgui.ImVec2{ .x = 1, .y = 1 });
}

pub fn ogImageButton(texture: imgui.ImTextureID, size: imgui.ImVec2, uv0: imgui.ImVec2, uv1: imgui.ImVec2, frame_padding: c_int) bool {
    return imgui.ogImageButtonEx(texture, size, uv0, uv1, frame_padding, .{}, .{ .x = 1, .y = 1, .z = 1, .w = 1 });
}

pub fn ogImageButtonEx(texture: imgui.ImTextureID, size: imgui.ImVec2, uv0: imgui.ImVec2, uv1: imgui.ImVec2, frame_padding: c_int, bg_col: imgui.ImVec4, tint_col: imgui.ImVec4) bool {
    _ = bg_col;
    _ = tint_col;
    return _ogImageButton(texture, &size, &uv0, &uv1, frame_padding);
}

pub fn ogColoredText(r: f32, g: f32, b: f32, text: [:0]const u8) void {
    _ogColoredText(r, g, b, text);
}

pub fn ogButton(label: [*c]const u8) bool {
    return _ogButton(label, 0, 0);
}

pub fn ogButtonEx(label: [*c]const u8, size: imgui.ImVec2) bool {
    return _ogButton(label, size.x, size.y);
}

pub fn ogImDrawData_ScaleClipRects(self: [*c]imgui.ImDrawData, fb_scale: imgui.ImVec2) void {
    _ogImDrawData_ScaleClipRects(self, fb_scale.x);
}

pub fn ogDockBuilderSetNodeSize(node_id: imgui.ImGuiID, size: imgui.ImVec2) void {
    _ogDockBuilderSetNodeSize(node_id, &size);
}

pub fn ogSetNextWindowPos(pos: imgui.ImVec2, cond: imgui.ImGuiCond, pivot: imgui.ImVec2) void {
    _ogSetNextWindowPos(&pos, cond, &pivot);
}

pub fn ogSetNextWindowSize(size: imgui.ImVec2, cond: imgui.ImGuiCond) void {
    _ogSetNextWindowSize(&size, cond);
}

pub fn ogPushStyleVarVec2(idx: imgui.ImGuiStyleVar, val: imgui.ImVec2) void {
    _ogPushStyleVarVec2(idx, val.x, val.y);
}

pub fn ogInvisibleButton(str_id: [*c]const u8, size: imgui.ImVec2, flags: imgui.ImGuiButtonFlags) bool {
    return _ogInvisibleButton(str_id, size.x, size.y, flags);
}

pub fn ogSelectableBool(label: [*c]const u8, selected: bool, flags: imgui.ImGuiSelectableFlags, size: imgui.ImVec2) bool {
    return _ogSelectableBool(label, selected, flags, size.x, size.y);
}

pub fn ogDummy(size: imgui.ImVec2) void {
    _ogDummy(size.x, size.y);
}

pub fn ogSetCursorPos(cursor: imgui.ImVec2) void {
    imgui.igSetCursorPosX(cursor.x);
    imgui.igSetCursorPosY(cursor.y);
}

pub fn ogBeginChildFrame(id: imgui.ImGuiID, size: imgui.ImVec2, flags: imgui.ImGuiWindowFlags) bool {
    return _ogBeginChildFrame(id, size.x, size.y, flags);
}

pub fn ogBeginChildEx(name: [*c]const u8, id: imgui.ImGuiID, size_arg: imgui.ImVec2, border: bool, flags: imgui.ImGuiWindowFlags) bool {
    return _ogBeginChildEx(name, id, &size_arg, border, flags);
}

pub fn ogDockSpace(id: imgui.ImGuiID, size: imgui.ImVec2, flags: imgui.ImGuiDockNodeFlags, window_class: [*c]const imgui.ImGuiWindowClass) void {
    _ogDockSpace(id, size.x, size.y, flags, window_class);
}

pub fn ogImDrawList_AddQuad(draw_list: [*c]imgui.ImDrawList, p1: *imgui.ImVec2, p2: *imgui.ImVec2, p3: *imgui.ImVec2, p4: *imgui.ImVec2, col: imgui.ImU32, thickness: f32) void {
    _ogImDrawList_AddQuad(draw_list, p1, p2, p3, p4, col, thickness);
}

pub fn ogImDrawList_AddQuadFilled(draw_list: [*c]imgui.ImDrawList, p1: *imgui.ImVec2, p2: *imgui.ImVec2, p3: *imgui.ImVec2, p4: *imgui.ImVec2, col: imgui.ImU32) void {
    _ogImDrawList_AddQuadFilled(draw_list, p1, p2, p3, p4, col);
}

pub fn ogImDrawList_AddImage(draw_list: [*c]imgui.ImDrawList, id: imgui.ImTextureID, p_min: imgui.ImVec2, p_max: imgui.ImVec2, uv_min: imgui.ImVec2, uv_max: imgui.ImVec2, col: imgui.ImU32) void {
    _ogImDrawList_AddImage(draw_list, id, &p_min, &p_max, &uv_min, &uv_max, col);
}

/// adds a rect outline with possibly non-matched width/height to the draw list
pub fn ogAddRect(draw_list: [*c]imgui.ImDrawList, tl: imgui.ImVec2, size: imgui.ImVec2, col: imgui.ImU32, thickness: f32) void {
    _ogImDrawList_AddQuad(draw_list, &imgui.ImVec2{ .x = tl.x, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size.x, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size.x, .y = tl.y + size.y }, &imgui.ImVec2{ .x = tl.x, .y = tl.y + size.y }, col, thickness);
}

pub fn ogImDrawList_AddLine(draw_list: [*c]imgui.ImDrawList, p1: imgui.ImVec2, p2: imgui.ImVec2, col: imgui.ImU32, thickness: f32) void {
    _ogImDrawList_AddLine(draw_list, &p1, &p2, col, thickness);
}

pub fn ogSetCursorScreenPos(pos: imgui.ImVec2) void {
    _ogSetCursorScreenPos(&pos);
}

pub fn ogListBoxHeaderVec2(label: [*c]const u8, size: imgui.ImVec2) bool {
    return _ogListBoxHeaderVec2(label, &size);
}

// just plain helper methods
pub fn ogOpenPopup(str_id: [*c]const u8) void {
    imgui.igOpenPopup(str_id, imgui.ImGuiPopupFlags_None);
}

pub fn ogColoredButton(color: imgui.ImU32, label: [:0]const u8) bool {
    return ogColoredButtonEx(color, label, .{});
}

pub fn ogColoredButtonEx(color: imgui.ImU32, label: [:0]const u8, size: imgui.ImVec2) bool {
    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, color);
    defer imgui.igPopStyleColor(1);
    return ogButtonEx(label, size);
}

pub fn ogPushIDUsize(id: usize) void {
    imgui.igPushIDInt(@intCast(c_int, id));
}

/// helper to shorten disabling controls via ogPushDisabled; defer ogPopDisabled; due to defer not working inside the if block.
pub fn ogPushDisabled(should_push: bool) void {
    if (should_push) {
        imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
        imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.7);
    }
}

pub fn ogPopDisabled(should_pop: bool) void {
    if (should_pop) {
        imgui.igPopItemFlag();
        imgui.igPopStyleVar(1);
    }
}

/// only true if down this frame and not down the previous frame
pub fn ogKeyPressed(key: usize) bool {
    return imgui.igGetIO().KeysDown[key] and imgui.igGetIO().KeysDownDuration[key] == 0;
}

/// true the entire time the key is down
pub fn ogKeyDown(key: usize) bool {
    return imgui.igGetIO().KeysDown[key];
}

/// true only the frame the key is released
pub fn ogKeyUp(key: usize) bool {
    return !imgui.igGetIO().KeysDown[key] and imgui.igGetIO().KeysDownDuration[key] == -1 and imgui.igGetIO().KeysDownDurationPrev[key] >= 0;
}

pub fn ogGetCursorScreenPos() imgui.ImVec2 {
    var pos = imgui.ImVec2{};
    imgui.igGetCursorScreenPos(&pos);
    return pos;
}

pub fn ogGetCursorPos() imgui.ImVec2 {
    var pos = imgui.ImVec2{};
    imgui.igGetCursorPos(&pos);
    return pos;
}

pub fn ogGetWindowSize() imgui.ImVec2 {
    var pos = imgui.ImVec2{};
    imgui.igGetWindowSize(&pos);
    return pos;
}

pub fn ogGetWindowPos() imgui.ImVec2 {
    var pos = imgui.ImVec2{};
    imgui.igGetWindowPos(&pos);
    return pos;
}

pub fn ogGetItemRectSize() imgui.ImVec2 {
    var size = imgui.ImVec2{};
    imgui.igGetItemRectSize(&size);
    return size;
}

pub fn ogGetItemRectMax() imgui.ImVec2 {
    var size = imgui.ImVec2{};
    imgui.igGetItemRectMax(&size);
    return size;
}

pub fn ogGetMouseDragDelta(button: imgui.ImGuiMouseButton, lock_threshold: f32) imgui.ImVec2 {
    var pos = imgui.ImVec2{};
    imgui.igGetMouseDragDelta(&pos, button, lock_threshold);
    return pos;
}

/// returns the drag delta of the mouse buttons that is dragging
pub fn ogGetAnyMouseDragDelta() imgui.ImVec2 {
    var drag_delta = imgui.ImVec2{};
    if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0)) {
        imgui.igGetMouseDragDelta(&drag_delta, imgui.ImGuiMouseButton_Left, 0);
    } else {
        imgui.igGetMouseDragDelta(&drag_delta, imgui.ImGuiMouseButton_Right, 0);
    }
    return drag_delta;
}

/// returns true if any mouse is dragging
pub fn ogIsAnyMouseDragging() bool {
    return imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0) or imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Right, 0);
}

pub fn ogIsAnyMouseDown() bool {
    return imgui.igIsMouseDown(imgui.ImGuiMouseButton_Left) or imgui.igIsMouseDown(imgui.ImGuiMouseButton_Right);
}

pub fn ogIsAnyMouseReleased() bool {
    return imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left) or imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Right);
}

pub fn ogGetContentRegionAvail() imgui.ImVec2 {
    var pos = imgui.ImVec2{};
    imgui.igGetContentRegionAvail(&pos);
    return pos;
}

pub fn ogGetWindowContentRegionMax() imgui.ImVec2 {
    var max = imgui.ImVec2{};
    imgui.igGetWindowContentRegionMax(&max);
    return max;
}

pub fn ogGetWindowCenter() imgui.ImVec2 {
    var max = ogGetWindowContentRegionMax();
    max.x /= 2;
    max.y /= 2;
    return max;
}

pub fn ogAddQuad(draw_list: [*c]imgui.ImDrawList, tl: imgui.ImVec2, size: f32, col: imgui.ImU32, thickness: f32) void {
    ogImDrawList_AddQuad(draw_list, &imgui.ImVec2{ .x = tl.x, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size, .y = tl.y + size }, &imgui.ImVec2{ .x = tl.x, .y = tl.y + size }, col, thickness);
}

pub fn ogAddQuadFilled(draw_list: [*c]imgui.ImDrawList, tl: imgui.ImVec2, size: f32, col: imgui.ImU32) void {
    ogImDrawList_AddQuadFilled(draw_list, &imgui.ImVec2{ .x = tl.x, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size, .y = tl.y + size }, &imgui.ImVec2{ .x = tl.x, .y = tl.y + size }, col);
}

/// adds a rect with possibly non-matched width/height to the draw list
pub fn ogAddRectFilled(draw_list: [*c]imgui.ImDrawList, tl: imgui.ImVec2, size: imgui.ImVec2, col: imgui.ImU32) void {
    ogImDrawList_AddQuadFilled(draw_list, &imgui.ImVec2{ .x = tl.x, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size.x, .y = tl.y }, &imgui.ImVec2{ .x = tl.x + size.x, .y = tl.y + size.y }, &imgui.ImVec2{ .x = tl.x, .y = tl.y + size.y }, col);
}

pub fn ogInputText(label: [*c]const u8, buf: [*c]u8, buf_size: usize) bool {
    return imgui.igInputText(label, buf, buf_size, imgui.ImGuiInputTextFlags_None, null, null);
}

/// adds an unformatted (igTextUnformatted) tooltip with a specific wrap width
pub fn ogUnformattedTooltip(text_wrap_pos: f32, text: [*c]const u8) void {
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        imgui.igBeginTooltip();
        defer imgui.igEndTooltip();

        imgui.igPushTextWrapPos(imgui.igGetFontSize() * text_wrap_pos);
        imgui.igTextUnformatted(text, null);
        imgui.igPopTextWrapPos();
    }
}

pub fn ogDrag(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T) bool {
    if (std.meta.trait.isUnsignedInt(T)) {
        return ogDragUnsignedFormat(T, label, p_data, v_speed, p_min, p_max, "%u");
    } else if (T == f32) {
        return ogDragSigned(T, label, p_data, v_speed, p_min, p_max);
    }
    return ogDragSigned(T, label, p_data, v_speed, p_min, p_max);
}

pub fn ogDragUnsignedFormat(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T, format: [*c]const u8) bool {
    std.debug.assert(std.meta.trait.isUnsignedInt(T));
    var min = p_min;
    var max = p_max;
    const data_type = switch (T) {
        u8 => imgui.ImGuiDataType_U8,
        u16 => imgui.ImGuiDataType_U16,
        u32 => imgui.ImGuiDataType_U32,
        usize => imgui.ImGuiDataType_U64,
        else => unreachable,
    };
    return imgui.igDragScalar(label, data_type, p_data, v_speed, &min, &max, format, 1);
}

pub fn ogDragSigned(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T) bool {
    var min = p_min;
    var max = p_max;
    const data_type = switch (T) {
        i16 => imgui.ImGuiDataType_S16,
        i32 => imgui.ImGuiDataType_S32,
        f32 => imgui.ImGuiDataType_Float,
        else => unreachable,
    };
    return imgui.igDragScalar(label, data_type, p_data, v_speed, &min, &max, "%.2f", 1);
}

pub fn ogDragSignedFormat(comptime T: type, label: [*c]const u8, p_data: *T, v_speed: f32, p_min: T, p_max: T, format: [*c]const u8) bool {
    var min = p_min;
    var max = p_max;
    const data_type = switch (T) {
        i16 => imgui.ImGuiDataType_S16,
        i32 => imgui.ImGuiDataType_S32,
        f32 => imgui.ImGuiDataType_Float,
        else => unreachable,
    };
    return imgui.igDragScalar(label, data_type, p_data, v_speed, &min, &max, format, 1);
}

pub fn ogColorConvertU32ToFloat4(in: imgui.ImU32) imgui.ImVec4 {
    var col = imgui.ImVec4{};
    imgui.igColorConvertU32ToFloat4(&col, in);
    return col;
}

pub fn ogColorConvertFloat4ToU32(in: imgui.ImVec4) imgui.ImU32 {
    return _ogColorConvertFloat4ToU32(&in);
}
