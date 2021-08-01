const std = @import("std");
const upaya = @import("upaya");
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

pub fn draw(state: *editor.AppState) void {
    _ = state;
    if (igBegin("Assets", null, ImGuiWindowFlags_None)) {}
    igEnd();
}
