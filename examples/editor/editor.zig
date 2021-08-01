const std = @import("std");
const upaya = @import("upaya");
const menu = @import("menu.zig");

const Color = upaya.math.Color;
usingnamespace @import("imgui");
usingnamespace @import("windows/windows.zig");

pub const colors = @import("colors.zig");

pub const AppState = @import("app_state.zig").AppState;

pub const Editor = struct {
    state: AppState,

    pub fn init() Editor {
        colors.init();
        return .{ .state = AppState.init() };
    }

    pub fn deinit(self: *Editor) void {
        _ = self;
    }

    pub fn handleDroppedFile(self: *Editor, file: []const u8) void {
        _ = self;
        _ = file;
    }

    pub fn update(self: *Editor) void {
        menu.draw(&self.state);

        scene_view.draw(&self.state);
        entities_win.draw(&self.state);
        inspector_win.draw(&self.state);
        assets_win.draw(&self.state);

        // igShowDemoWindow(null);
    }

    pub fn setupDockLayout(id: ImGuiID) void {
        var dock_main_id = id;

        // dock_main_id is the left node after this
        const right_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Right, 0.3, null, &dock_main_id);

        // bottom_right_id is the bottom node after this
        var bottom_right_id: ImGuiID = 0;
        const top_right_id = igDockBuilderSplitNode(right_id, ImGuiDir_Up, 0.5, null, &bottom_right_id);
        igDockBuilderDockWindow("Entities", top_right_id);
        igDockBuilderDockWindow("Inspector", bottom_right_id);

        // dock_main_id is the bottom node after this
        const tl_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Up, 0.6, null, &dock_main_id);
        igDockBuilderDockWindow("Scene", tl_id);
        igDockBuilderDockWindow("Assets", dock_main_id);

        igDockBuilderFinish(id);
    }
};
