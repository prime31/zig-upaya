const std = @import("std");
const upaya = @import("upaya");
usingnamespace upaya.imgui;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .setupDockLayout = setupDockLayout,
        .docking = true,
    });
}

fn init() void {}

fn update() void {
    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            _ = igMenuItemBool("New", "cmd+n", false, true);
            _ = igMenuItemBool("Save", "cmd+s", false, true);
        }

        if (igBeginMenu("Edit", true)) {
            defer igEndMenu();

            _ = igMenuItemBool("Copy", "cmd+c", false, true);
            _ = igMenuItemBool("Paste", "cmd+v", false, true);
        }
    }

    _ = igBegin("Properties", null, ImGuiWindowFlags_None);
    igEnd();

    _ = igBegin("Top Left", null, ImGuiWindowFlags_None);
    igEnd();

    _ = igBegin("Bottom Left 1", null, ImGuiWindowFlags_None);
    igEnd();

    _ = igBegin("Bottom Left 2", null, ImGuiWindowFlags_None);
    igEnd();

    igSetNextWindowSize(.{ .x = 100, .y = 75 }, ImGuiCond_FirstUseEver);
    _ = igBegin("Floating", null, ImGuiWindowFlags_None);
    igEnd();
}

fn setupDockLayout(id: ImGuiID) void {
    var dock_main_id = id;

    // dock_main_id is the left node after this
    const right_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Right, 0.37, null, &dock_main_id);
    igDockBuilderDockWindow("Properties", right_id);

    // dock_main_id is the bottom node after this
    const tl_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Up, 0.48, null, &dock_main_id);
    igDockBuilderDockWindow("Top Left", tl_id);

    igDockBuilderDockWindow("Bottom Left 1", dock_main_id);
    igDockBuilderDockWindow("Bottom Left 2", dock_main_id);

    igDockBuilderFinish(id);
}
