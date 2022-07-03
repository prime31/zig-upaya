const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const editor = @import("../editor.zig");
const Color = math.Color;
const imgui = @import("imgui");

const Camera = struct {
    pos: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn transMat(self: Camera) math.Mat32 {
        var window_half_size = imgui.ogGetWindowSize().scale(0.5);

        var transform = math.Mat32.identity;

        var tmp = math.Mat32.identity;
        tmp.translate(-self.pos.x, -self.pos.y);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.translate(window_half_size.x, window_half_size.y);
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn clampZoom(self: *Camera) void {
        self.zoom = std.math.clamp(self.zoom, 0.1, 5);
    }
};

var trans_mat: math.Mat32 = undefined;
var camera: Camera = .{};
var screen_pos: imgui.ImVec2 = undefined;

var tex: ?upaya.Texture = null;

pub fn draw(state: *editor.AppState) void {
    _ = state;
    if (tex == null) tex = upaya.Texture.initFromFile("examples/assets/plant.png", .nearest) catch unreachable;

    if (begin("Scene")) {
        drawRect(.{}, 10, Color.white);
        drawRect(.{ .x = 30, .y = 30 }, 20, Color.dark_blue);
        if (upaya.math.isEven(@divTrunc(std.time.milliTimestamp(), 1000)))
            drawHollowRect(.{ .x = 30, .y = 30 }, .{ .x = 20, .y = 20 }, 3, Color.red);
        drawRect(.{ .x = 130, .y = 130 }, 20, Color.yellow);
        drawRect(.{ .x = 430, .y = 230 }, 20, Color.voilet);
        drawRect(.{ .x = 630, .y = 330 }, 20, Color.green);

        drawTex(tex.?, .{});
        drawTexPortion(tex.?, .{ .x = -100, .y = -100 }, .{ .x = 0, .y = 0, .w = 18, .h = 18 });
        drawTexPortion(tex.?, .{ .x = -82, .y = -100 }, .{ .x = 18, .y = 0, .w = 18, .h = 18 });
        drawTexPortion(tex.?, .{ .x = -82, .y = -82 }, .{ .x = 18, .y = 18, .w = 18, .h = 18 });
        drawTexPortion(tex.?, .{ .x = -100, .y = -82 }, .{ .x = 0, .y = 18, .w = 18, .h = 18 });

        drawText("Text at origin", .{});
    }
    end();
}

fn begin(name: [*c]const u8) bool {
    if (!imgui.igBegin(name, null, imgui.ImGuiWindowFlags_None)) return false;
    screen_pos = imgui.ogGetCursorScreenPos();
    const win_size = imgui.ogGetContentRegionAvail();
    if (win_size.x == 0 or win_size.y == 0) return false;

    imgui.igSetCursorPosX(win_size.x - 150);
    imgui.igSetNextItemWidth(100);
    _ = imgui.igDragFloat2("Position", &camera.pos.x, 1, std.math.f32_min, std.math.f32_min, "%.1f", 1);
    imgui.igSameLine(0, 0);
    imgui.igSetNextItemWidth(75);
    imgui.igSetCursorPosX(win_size.x - 300);

    _=  imgui.ogDrag(f32, "Zoom", &camera.zoom, 0.01, 0.1, 4);

    // all controls need to be done by now
    imgui.igSetCursorScreenPos(screen_pos);
    _ = imgui.igInvisibleButton("##scene_view", win_size);
    const is_hovered = imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None);

    trans_mat = camera.transMat();

    if (is_hovered)
        handleInput();

    return true;
}

fn end() void {
    imgui.igEnd();
}

fn handleInput() void {
    // scrolling via drag with alt or super key down
    if (imgui.igIsMouseDragging(imgui.ImGuiMouseButton_Left, 0) and (imgui.igGetIO().KeyAlt or imgui.igGetIO().KeySuper)) {
        var scroll_delta = imgui.ogGetMouseDragDelta(imgui.ImGuiMouseButton_Left, 0);

        camera.pos.x -= scroll_delta.x * 1 / camera.zoom;
        camera.pos.y -= scroll_delta.y * 1 / camera.zoom;
        imgui.igResetMouseDragDelta(imgui.ImGuiMouseButton_Left);
        return;
    }

    if (imgui.igGetIO().MouseWheel != 0) {
        camera.zoom += imgui.igGetIO().MouseWheel * 0.05;
        camera.clampZoom();
        imgui.igGetIO().MouseWheel = 0;
    }
}

// rendering methods
pub fn drawRect(center: math.Vec2, size: f32, color: math.Color) void {
    const half_size = size / 2;
    var tl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y - half_size });
    var tr = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y - half_size });
    var br = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y + half_size });
    var bl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y + half_size });

    imgui.ImDrawList_AddQuadFilled(imgui.igGetWindowDrawList(), tl.add(screen_pos), tr.add(screen_pos), br.add(screen_pos), bl.add(screen_pos), color.value);
}

pub fn drawHollowRect(center: math.Vec2, size: math.Vec2, thickness: f32, color: math.Color) void {
    const half_size = size.scale(0.5);
    var tl = trans_mat.transformImVec2(.{ .x = center.x - half_size.x, .y = center.y - half_size.y });
    var tr = trans_mat.transformImVec2(.{ .x = center.x + half_size.x, .y = center.y - half_size.y });
    var br = trans_mat.transformImVec2(.{ .x = center.x + half_size.x, .y = center.y + half_size.y });
    var bl = trans_mat.transformImVec2(.{ .x = center.x - half_size.x, .y = center.y + half_size.y });

    imgui.ImDrawList_AddQuad(imgui.igGetWindowDrawList(), tl.add(screen_pos), tr.add(screen_pos), br.add(screen_pos), bl.add(screen_pos), color.value, thickness);
}

pub fn drawText(text: [*c]const u8, top_left: imgui.ImVec2) void {
    const tl = trans_mat.transformImVec2(top_left);
    imgui.ImDrawList_AddTextVec2(imgui.igGetWindowDrawList(), tl.add(screen_pos), 0xffffffff, text, null);
}

pub fn drawTex(texture: upaya.Texture, pos: imgui.ImVec2) void {
    const tl = trans_mat.transformImVec2(pos);
    var br = pos;
    br.x += @intToFloat(f32, texture.width);
    br.y += @intToFloat(f32, texture.height);
    br = trans_mat.transformImVec2(br);

    imgui.ImDrawList_AddImage(imgui.igGetWindowDrawList(), texture.imTextureID(), tl.add(screen_pos), br.add(screen_pos), .{}, .{ .x = 1, .y = 1 }, 0xffffffff);
}

pub fn drawTexPortion(texture: upaya.Texture, pos: imgui.ImVec2, rect: math.Rect) void {
    const tl = trans_mat.transformImVec2(pos);
    var br = pos;
    br.x += rect.w;
    br.y += rect.h;
    br = trans_mat.transformImVec2(br);

    const inv_w = 1.0 / @intToFloat(f32, texture.width);
    const inv_h = 1.0 / @intToFloat(f32, texture.height);

    const uv0 = imgui.ImVec2{ .x = rect.x * inv_w, .y = rect.y * inv_h };
    const uv1 = imgui.ImVec2{ .x = (rect.x + rect.w) * inv_w, .y = (rect.y + rect.h) * inv_h };

    imgui.ImDrawList_AddImage(imgui.igGetWindowDrawList(), texture.imTextureID(), tl.add(screen_pos), br.add(screen_pos), uv0, uv1, 0xffffffff);
}
