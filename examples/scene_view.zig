const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
usingnamespace upaya.imgui;

var cam = Camera{};

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {}

fn update() void {
    if (SceneView.begin("Game View")) {

    }
    SceneView.end();
}

fn handleInput() void {
    // scrolling via drag with alt or super key down
    if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
        var scroll_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0);
        cam.pos.x -= scroll_delta.x;
        cam.pos.y -= scroll_delta.y;
        igResetMouseDragDelta(ImGuiMouseButton_Left);
        return;
    }
}

pub const SceneView = struct {
    fn begin(name: [*c]const u8) bool {
        if (!igBegin(name, null, ImGuiWindowFlags_None)) return false;
        const pos = ogGetCursorScreenPos();
        const win_size = ogGetContentRegionAvail();

        igSetCursorPosX(win_size.x - 150);
        igSetNextItemWidth(100);
        _ = igDragFloat2("Position", &cam.pos.x, 1, std.math.f32_min, std.math.f32_min, "%.1f", 1);

        // all controls need to be done by now
        igSetCursorScreenPos(pos);
        _ = igInvisibleButton("##scene_view", win_size);

        const box_pos = cam.invTransMat().transformImVec2(pos);
        ogAddQuadFilled(igGetWindowDrawList(), box_pos, 20, upaya.math.Color.white.value);

        handleInput();

        return true;
    }

    fn end() void {
        igEnd();
    }

    fn drawQuadFilled(pos: math.Vec2) void {

    }
};

pub const Camera = struct {
    pos: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn invTransMat(self: Camera) math.Mat32 {
        return math.Mat32.initTransform(.{ .x = self.pos.x, .y = self.pos.y, .sx = self.zoom, .sy = self.zoom }).inverse();
    }
};
