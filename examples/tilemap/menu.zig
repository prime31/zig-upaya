const std = @import("std");
const upaya = @import("upaya");
const imgui = @import("imgui");


pub fn draw() void {
    if (imgui.igBeginMenuBar()) {
        defer imgui.igEndMenuBar();

        if (imgui.igBeginMenu("File", true)) {
            defer imgui.igEndMenu();

            if (imgui.igMenuItemBool("New", null, false, true)) {}
        }

        if (imgui.igBeginMenu("Tools", true)) {
            defer imgui.igEndMenu();

            if (imgui.igMenuItemBool("Nothing Yet...", null, false, true)) {}
        }
    }
}
