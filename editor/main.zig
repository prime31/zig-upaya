const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const Color = math.Color;
usingnamespace @import("windows/windows.zig");
usingnamespace @import("imgui");

var tex: upaya.Texture = undefined;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .setupDockLayout = setupDockLayout,
        .window_title = "Upaya Edit",
    });
}

fn init() void {
    tex = upaya.Texture.initFromFile("examples/assets/plant.png", .nearest) catch unreachable;
}

fn update() void {
    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();
        }
    }

    if (scene_view.begin("Scene")) {
        scene_view.drawRect(.{}, 10, Color.white);
        scene_view.drawRect(.{ .x = 30, .y = 30 }, 20, Color.dark_blue);
        if (math.isEven(@divTrunc(std.time.milliTimestamp(), 1000)))
            scene_view.drawHollowRect(.{ .x = 30, .y = 30 }, .{ .x = 20, .y = 20 }, 3, Color.red);
        scene_view.drawRect(.{ .x = 130, .y = 130 }, 20, Color.yellow);
        scene_view.drawRect(.{ .x = 430, .y = 230 }, 20, Color.voilet);
        scene_view.drawRect(.{ .x = 630, .y = 330 }, 20, Color.green);

        scene_view.drawTex(tex, .{});
        scene_view.drawTexPortion(tex, .{ .x = -100, .y = -100 }, .{ .x = 0, .y = 0, .w = 18, .h = 18 });
        scene_view.drawTexPortion(tex, .{ .x = -82, .y = -100 }, .{ .x = 18, .y = 0, .w = 18, .h = 18 });
        scene_view.drawTexPortion(tex, .{ .x = -82, .y = -82 }, .{ .x = 18, .y = 18, .w = 18, .h = 18 });
        scene_view.drawTexPortion(tex, .{ .x = -100, .y = -82 }, .{ .x = 0, .y = 18, .w = 18, .h = 18 });

        scene_view.drawText("Text at origin", .{});
    }
    scene_view.end();

    _ = igBegin("Entities", null, ImGuiWindowFlags_None);
    ogAddRectFilled(igGetWindowDrawList(), ogGetCursorScreenPos(), ogGetContentRegionAvail(), upaya.colors.rgbToU32(0, 0, 0));
    igEnd();

    _ = igBegin("Inspector", null, ImGuiWindowFlags_None);
    ogAddRectFilled(igGetWindowDrawList(), ogGetCursorScreenPos(), ogGetContentRegionAvail(), upaya.colors.rgbToU32(0, 0, 0));
    igEnd();

    _ = igBegin("Assets", null, ImGuiWindowFlags_None);
    ogAddRectFilled(igGetWindowDrawList(), ogGetCursorScreenPos(), ogGetContentRegionAvail(), upaya.colors.rgbToU32(0, 0, 0));
    igEnd();
}

fn setupDockLayout(id: ImGuiID) void {
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
