const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const Color = math.Color;
usingnamespace upaya.imgui;

var cam = Camera{ .pos = .{ .x = 0, .y = 0 } };
var tex: upaya.Texture = undefined;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {
    tex = upaya.Texture.initFromFile("examples/assets/plant.png", .nearest) catch unreachable;
}

fn update() void {
    if (SceneView.begin("Game View")) {
    SceneView.drawRect(.{}, 10, math.Color.white);
    SceneView.drawRect(.{ .x = 30, .y = 30 }, 20, math.Color.dark_blue);
    SceneView.drawRect(.{ .x = 130, .y = 130 }, 20, math.Color.yellow);
    SceneView.drawRect(.{ .x = 430, .y = 230 }, 20, math.Color.voilet);
    SceneView.drawRect(.{ .x = 630, .y = 330 }, 20, math.Color.green);

    SceneView.drawTex(tex, .{});
    SceneView.drawTexPortion(tex, .{ .x = -100, .y = -100 }, .{ .x = 0, .y = 0, .w = 18, .h = 18 });
    SceneView.drawTexPortion(tex, .{ .x = -82, .y = -100 }, .{ .x = 18, .y = 0, .w = 18, .h = 18 });
    SceneView.drawTexPortion(tex, .{ .x = -82, .y = -82 }, .{ .x = 18, .y = 18, .w = 18, .h = 18 });
    SceneView.drawTexPortion(tex, .{ .x = -100, .y = -82 }, .{ .x = 0, .y = 18, .w = 18, .h = 18 });

    SceneView.drawText("Text at origin", .{});
    }
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

            cam.pos.x -= scroll_delta.x;
            cam.pos.y -= scroll_delta.y;
            igResetMouseDragDelta(ImGuiMouseButton_Left);
            return;
        }

        if (igGetIO().MouseWheel != 0) {
            cam.zoom += igGetIO().MouseWheel * 0.05;
            cam.clampZoom();
            igGetIO().MouseWheel = 0;
        }
    }

    fn drawRect(center: math.Vec2, size: f32, color: math.Color) void {
        const half_size = size / 2;
        var tl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y - half_size });
        var tr = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y - half_size });
        var br = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y + half_size });
        var bl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y + half_size });

        ImDrawList_AddQuadFilled(igGetWindowDrawList(), tl.add(screen_pos), tr.add(screen_pos), br.add(screen_pos), bl.add(screen_pos), color.value);
    }

    fn drawText(text: [*c]const u8, top_left: ImVec2) void {
        const tl = trans_mat.transformImVec2(top_left);
        ImDrawList_AddTextVec2(igGetWindowDrawList(), tl.add(screen_pos), 0xffffffff, text, null);
    }

    fn drawTex(texture: upaya.Texture, pos: ImVec2) void {
        const tl = trans_mat.transformImVec2(pos);
        var br = pos;
        br.x += @intToFloat(f32, texture.width);
        br.y += @intToFloat(f32, texture.height);
        br = trans_mat.transformImVec2(br);

        ImDrawList_AddImage(igGetWindowDrawList(), texture.imTextureID(), tl.add(screen_pos), br.add(screen_pos), .{}, .{ .x = 1, .y = 1 }, 0xffffffff);
    }

    fn drawTexPortion(texture: upaya.Texture, pos: ImVec2, rect: math.Rect) void {
        const tl = trans_mat.transformImVec2(pos);
        var br = pos;
        br.x += rect.w;
        br.y += rect.h;
        br = trans_mat.transformImVec2(br);

        const inv_w = 1.0 / @intToFloat(f32, texture.width);
        const inv_h = 1.0 / @intToFloat(f32, texture.height);

        const uv0 = ImVec2{ .x = rect.x * inv_w, .y = rect.y * inv_h };
        const uv1 = ImVec2{ .x = (rect.x + rect.w) * inv_w, .y = (rect.y + rect.h) * inv_h };

        ImDrawList_AddImage(igGetWindowDrawList(), texture.imTextureID(), tl.add(screen_pos), br.add(screen_pos), uv0, uv1, 0xffffffff);
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

        var transform = math.Mat32.identity;

        var tmp = math.Mat32.identity;
        tmp.translate(-self.pos.x, -self.pos.y);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.translate(size.x / 2, size.y / 2);
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn clampZoom(self: *Camera) void {
        self.zoom = std.math.clamp(self.zoom, 0.1, 5);
    }
};
