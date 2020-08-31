const std = @import("std");
const upaya = @import("upaya");
usingnamespace @import("imgui");


pub fn draw() void {
    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New", null, false, true)) {}
        }

        if (igBeginMenu("Tools", true)) {
            defer igEndMenu();

            if (igMenuItemBool("Nothing Yet...", null, false, true)) {}
        }
    }
}
