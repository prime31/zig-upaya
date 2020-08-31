const std = @import("std");
usingnamespace @import("imgui");

const colors = @import("../colors.zig");
const Tilemap = @import("tilemap.zig").Tilemap;

pub const TilemapEditor = struct {
    shift_dragged: bool = false,
    dragged: bool = false,
    prev_mouse_pos: ImVec2 = .{},

    pub fn init() TilemapEditor {
        return .{};
    }

    pub fn deinit(self: @This()) void {}

    pub fn draw(self: @This(), name: [*c]const u8) void {
        // if the alt key is down dont allow scrolling with the mouse wheel since we will be zooming with it
        var window_flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar;
        if (igGetIO().KeyAlt) window_flags |= ImGuiWindowFlags_NoScrollWithMouse;

        defer igEnd();
        if (!igBegin(name, null, window_flags)) return;

        var pos = ogGetCursorScreenPos();
        ogAddRectFilled(igGetWindowDrawList(), pos, map_size, colors.rgbToU32(0, 0, 0));

        _ = igInvisibleButton("##input_map_button", map_size);
        const is_hovered = igIsItemHovered(ImGuiHoveredFlags_None);

        if (is_hovered) handleInput(pos);
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
};
