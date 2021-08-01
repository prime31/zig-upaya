const std = @import("std");
const upaya = @import("upaya");
const editor = @import("editor.zig");
usingnamespace @import("imgui");

const comp_editor = @import("windows/component_editor.zig");

pub fn draw(state: *editor.AppState) void {
    var show_component_editor_popup = false;

    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New", null, false, true)) {}
        }

        if (igBeginMenu("Tools", true)) {
            defer igEndMenu();

            if (igMenuItemBool("Component Editor...", null, false, true)) {
                show_component_editor_popup = true;
            }
        }
    }

    // handle popup toggles
    if (show_component_editor_popup) {
        igOpenPopup("Component Editor");
    }

    // we always need to call our popup code
    comp_editor.draw(state);
}
