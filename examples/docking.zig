const std = @import("std");
const upaya = @import("upaya");
const imgui = upaya.imgui;

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
    // note: the MenuItems do not automatically bind to keys. The shortcut field is just for the UI. You can add listeners for the key combos
    // like this:
    const io = imgui.igGetIO();
    if ((io.KeyCtrl or io.KeySuper) and imgui.ogKeyPressed(upaya.sokol.SAPP_KEYCODE_S)) {
        onSave();
    }

    upaya.menu.draw(&[_]upaya.MenuItem{ .{
        .label = "File",
        .children = &[_]upaya.MenuItem{
            .{ .label = "New", .shortcut = "cmd+n" },
            .{ .label = "Save", .shortcut = "cmd+s", .action = onSave },
        },
    }, .{
        .label = "Edit",
        .children = &[_]upaya.MenuItem{
            .{ .label = "Copy", .shortcut = "cmd+c" },
            .{ .label = "Paste", .shortcut = "cmd+v" },
        },
    } });

    _ = imgui.igBegin("Properties", null, imgui.ImGuiWindowFlags_None);
    imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), imgui.ogGetCursorScreenPos(), imgui.ogGetContentRegionAvail(), upaya.colors.rgbToU32(255, 0, 0));
    imgui.igEnd();

    _ = imgui.igBegin("Top Left", null, imgui.ImGuiWindowFlags_None);
    imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), imgui.ogGetCursorScreenPos(), imgui.ogGetContentRegionAvail(), upaya.colors.rgbToU32(0, 0, 255));
    imgui.igEnd();

    _ = imgui.igBegin("Bottom Left 1", null, imgui.ImGuiWindowFlags_None);
    imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), imgui.ogGetCursorScreenPos(), imgui.ogGetContentRegionAvail(), upaya.colors.rgbToU32(0, 255, 0));
    imgui.igEnd();

    _ = imgui.igBegin("Bottom Left 2", null, imgui.ImGuiWindowFlags_None);
    imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), imgui.ogGetCursorScreenPos(), imgui.ogGetContentRegionAvail(), upaya.colors.rgbToU32(100, 100, 100));
    imgui.igEnd();

    imgui.igSetNextWindowSize(.{ .x = 100, .y = 75 }, imgui.ImGuiCond_FirstUseEver);
    _ = imgui.igBegin("Floating", null, imgui.ImGuiWindowFlags_None);
    imgui.igEnd();
}

fn onSave() void {
    var file = upaya.filebrowser.saveFileDialog("Save File", "", "*.txt");
    if (file != null) {
        std.debug.print("save file: {s}\n", .{file});
    }
}

fn setupDockLayout(id: imgui.ImGuiID) void {
    var dock_main_id = id;

    // dock_main_id is the left node after this
    const right_id = imgui.igDockBuilderSplitNode(dock_main_id, imgui.ImGuiDir_Right, 0.35, null, &dock_main_id);
    imgui.igDockBuilderDockWindow("Properties", right_id);

    // dock_main_id is the bottom node after this
    const tl_id = imgui.igDockBuilderSplitNode(dock_main_id, imgui.ImGuiDir_Up, 0.48, null, &dock_main_id);
    imgui.igDockBuilderDockWindow("Top Left", tl_id);

    imgui.igDockBuilderDockWindow("Bottom Left 1", dock_main_id);
    imgui.igDockBuilderDockWindow("Bottom Left 2", dock_main_id);

    imgui.igDockBuilderFinish(id);
}
