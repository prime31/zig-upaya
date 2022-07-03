const std = @import("std");
const upaya = @import("upaya");
const editor = @import("../editor.zig");
const imgui = @import("imgui");

pub fn draw(state: *editor.AppState) void {
    _ = state;
    if (imgui.igBegin("Entities", null, imgui.ImGuiWindowFlags_None)) {}
    imgui.igEnd();
}
