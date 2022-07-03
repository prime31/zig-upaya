const std = @import("std");
const upaya = @import("upaya");
const editor = @import("editor.zig");
const imgui = @import("imgui");

const comp_editor = @import("windows/component_editor.zig");

pub fn draw(state: *editor.AppState) void {
    var show_component_editor_popup = false;

    if (imgui.igBeginMenuBar()) {
        defer imgui.igEndMenuBar();

        if (imgui.igBeginMenu("File", true)) {
            defer imgui.igEndMenu();

            if (imgui.igMenuItemBool("New", null, false, true)) {}
        }

        if (imgui.igBeginMenu("Tools", true)) {
            defer imgui.igEndMenu();

            if (imgui.igMenuItemBool("Component Editor...", null, false, true)) {
                show_component_editor_popup = true;
            }
        }
    }

    // handle popup toggles
    if (show_component_editor_popup) {
        imgui.igOpenPopup("Component Editor");
    }

    // we always need to call our popup code
    comp_editor.draw(state);
}
