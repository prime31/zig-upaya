const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
usingnamespace upaya.imgui;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {}

fn update() void {
    ogBeginGameView("Game View");
    ogEndGameView();
}

fn ogBeginGameView(name: [*c]const u8) void {
    _ = igBegin(name, null, ImGuiWindowFlags_None);
    const pos = ogGetCursorScreenPos();


    ogAddQuadFilled(igGetWindowDrawList(), pos, 20, upaya.math.Color.white.value);
}

fn ogEndGameView() void {
    igEnd();
}

pub const Camera = struct {
    pos: math.Vec2,
    zoom: f32 = 1,

    pub fn invTransMat(self: Camera) math.Mat32 {
        return math.Mat32.initTransform(.{ .x = self.pos.x, .y = self.pos.y, .sx = self.zoom, .sy = self.zoom }).inverse();
    }
};
