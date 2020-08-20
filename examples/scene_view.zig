const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const Color = math.Color;
usingnamespace upaya.imgui;

var cam = Camera{ .pos = .{ .x = 0, .y = 0 } };

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {}

fn update() void {
    if (SceneView.begin("Game View")) {}
    SceneView.drawRect(.{}, 10, math.Color.blue);
    SceneView.drawRect(.{ .x = 30, .y = 30 }, 20, math.Color.dark_blue);
    SceneView.drawRect(.{ .x = 130, .y = 130 }, 20, math.Color.yellow);
    SceneView.drawRect(.{ .x = 430, .y = 230 }, 20, math.Color.voilet);
    SceneView.drawRect(.{ .x = 630, .y = 330 }, 20, math.Color.green);
    SceneView.end();
}

pub const SceneView = struct {
    var trans_mat: math.Mat32 = undefined;
    var camera: Camera = undefined;
    var screen_pos: ImVec2 = undefined;

    fn begin(name: [*c]const u8) bool {
        if (!igBegin(name, null, ImGuiWindowFlags_None)) return false;
        screen_pos = ogGetCursorScreenPos();
        const win_size = ogGetContentRegionAvail();

        igSetCursorPosX(win_size.x - 150);
        igSetNextItemWidth(100);
        _ = igDragFloat2("Position", &cam.pos.x, 1, std.math.f32_min, std.math.f32_min, "%.1f", 1);
        igSameLine(0, 0);
        igSetNextItemWidth(75);
        igSetCursorPosX(win_size.x - 300);

        // TODO: when zooming center around the mouse cursor
        // var old_size = ogGetWindowSize().scale(cam.zoom);
        if (ogDrag(f32, "Zoom", &cam.zoom, 0.01, 0.1, 4)) {
            // var delta_size = old_size.subtract(ogGetWindowSize().scale(cam.zoom)).scale(0.3);
            // cam.pos = cam.pos.add(.{ .x = delta_size.x, .y = delta_size.y });
        }

        // all controls need to be done by now
        igSetCursorScreenPos(screen_pos);
        _ = igInvisibleButton("##scene_view", win_size);
        const is_hovered = igIsItemHovered(ImGuiHoveredFlags_None);

        camera = cam;
        trans_mat = cam.transMat();

        if (is_hovered)
            handleInput();

        return true;
    }

    fn end() void {
        igEnd();
    }

    fn handleInput() void {
        // scrolling via drag with alt or super key down
        if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
            var scroll_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0);

            cam.pos.x += scroll_delta.x;
            cam.pos.y += scroll_delta.y;
            igResetMouseDragDelta(ImGuiMouseButton_Left);
            return;
        }
    }

    fn drawRect(center: math.Vec2, size: f32, color: math.Color) void {
        const half_size = size / 2;
        const real_center = center.subtract(.{ .x = cam.pos.x, .y = cam.pos.y });
        var tl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y - half_size });
        var tr = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y - half_size });
        var br = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y + half_size });
        var bl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y + half_size });

        // tl = ImVec2{ .x = real_center.x - half_size, .y = real_center.y - half_size };
        // tr = ImVec2{ .x = real_center.x + half_size, .y = real_center.y - half_size };
        // br = ImVec2{ .x = real_center.x + half_size, .y = real_center.y + half_size };
        // bl = ImVec2{ .x = real_center.x - half_size, .y = real_center.y + half_size };
        // tl = tl.scale(cam.zoom);
        // tr = tr.scale(cam.zoom);
        // br = br.scale(cam.zoom);
        // bl = bl.scale(cam.zoom);

        ImDrawList_AddQuadFilled(igGetWindowDrawList(), tl.add(screen_pos), tr.add(screen_pos), br.add(screen_pos), bl.add(screen_pos), color.value);
    }
};

pub const Camera = struct {
    pos: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn invTransMat(self: Camera) math.Mat32 {
        var size = ogGetWindowSize();
        // var ortho = math.Mat32.initOrtho(size.x, size.y);
        // var trans = math.Mat32.initTransform(.{ .x = self.pos.x, .y = self.pos.y, .sx = self.zoom, .sy = self.zoom });
        // return ortho.mul(trans);

        // return math.Mat32.initTransform(.{ .x = self.pos.x, .y = self.pos.y, .sx = self.zoom, .sy = self.zoom }).inverse();
        return math.Mat32.initTransform(.{ .x = self.pos.x - size.x / 2, .y = self.pos.y - size.y / 2, .sx = self.zoom, .sy = self.zoom }).inverse();

        // return math.Mat32.initTransform(.{ .x = self.pos.x, .y = self.pos.y, .sx = self.zoom, .sy = self.zoom, .ox = size.x / 2, .oy = size.y / 2 }).inverse();
    }

    pub fn transMat(self: Camera) math.Mat32 {
        var size = ogGetWindowSize();

        // var transform = math.Mat32.identity;

        // var tmp = math.Mat32.identity;
        // tmp.translate(-self.pos.x, -self.pos.y);
        // transform = transform.mul(tmp);

        // tmp = math.Mat32.identity;
        // tmp.scale(self.zoom, self.zoom);
        // transform = transform.mul(tmp);

        // tmp = math.Mat32.identity;
        // tmp.translate(size.x, size.y);
        // transform = transform.mul(tmp);

        // return transform;

        return math.Mat32.initTransform(.{ .x = self.pos.x + size.x / 2, .y = self.pos.y + size.y / 2, .sx = self.zoom, .sy = self.zoom });
        // return math.Mat32.initTransform(.{ .x = self.pos.x, .y = self.pos.y, .sx = self.zoom, .sy = self.zoom, .ox = size.x / 2, .oy = size.y / 2 });
    }
};
