const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const Color = math.Color;
usingnamespace @import("imgui");

const Camera = struct {
    pos: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn transMat(self: Camera) math.Mat32 {
        var window_half_size = ogGetWindowSize().scale(0.5);

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
var screen_pos: ImVec2 = undefined;

pub fn begin(name: [*c]const u8) bool {
    if (!igBegin(name, null, ImGuiWindowFlags_None)) return false;
    screen_pos = ogGetCursorScreenPos();
    const win_size = ogGetContentRegionAvail();
    if (win_size.x == 0 or win_size.y == 0) return false;

    igSetCursorPosX(win_size.x - 150);
    igSetNextItemWidth(100);
    _ = igDragFloat2("Position", &camera.pos.x, 1, std.math.f32_min, std.math.f32_min, "%.1f", 1);
    igSameLine(0, 0);
    igSetNextItemWidth(75);
    igSetCursorPosX(win_size.x - 300);

    _ = ogDrag(f32, "Zoom", &camera.zoom, 0.01, 0.1, 4);

    // all controls need to be done by now
    igSetCursorScreenPos(screen_pos);
    _ = igInvisibleButton("##scene_view", win_size);
    const is_hovered = igIsItemHovered(ImGuiHoveredFlags_None);

    trans_mat = camera.transMat();

    if (is_hovered)
        handleInput();

    return true;
}

pub fn end() void {
    igEnd();
}

fn handleInput() void {
    // scrolling via drag with alt or super key down
    if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
        var scroll_delta = ogGetMouseDragDelta(ImGuiMouseButton_Left, 0);

        camera.pos.x -= scroll_delta.x * 1 / camera.zoom;
        camera.pos.y -= scroll_delta.y * 1 / camera.zoom;
        igResetMouseDragDelta(ImGuiMouseButton_Left);
        return;
    }

    if (igGetIO().MouseWheel != 0) {
        camera.zoom += igGetIO().MouseWheel * 0.05;
        camera.clampZoom();
        igGetIO().MouseWheel = 0;
    }
}

pub fn drawRect(center: math.Vec2, size: f32, color: math.Color) void {
    const half_size = size / 2;
    var tl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y - half_size });
    var tr = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y - half_size });
    var br = trans_mat.transformImVec2(.{ .x = center.x + half_size, .y = center.y + half_size });
    var bl = trans_mat.transformImVec2(.{ .x = center.x - half_size, .y = center.y + half_size });

    ImDrawList_AddQuadFilled(igGetWindowDrawList(), tl.add(screen_pos), tr.add(screen_pos), br.add(screen_pos), bl.add(screen_pos), color.value);
}

pub fn drawHollowRect(center: math.Vec2, size: math.Vec2, thickness: f32, color: math.Color) void {
    const half_size = size.scale(0.5);
    var tl = trans_mat.transformImVec2(.{ .x = center.x - half_size.x, .y = center.y - half_size.y });
    var tr = trans_mat.transformImVec2(.{ .x = center.x + half_size.x, .y = center.y - half_size.y });
    var br = trans_mat.transformImVec2(.{ .x = center.x + half_size.x, .y = center.y + half_size.y });
    var bl = trans_mat.transformImVec2(.{ .x = center.x - half_size.x, .y = center.y + half_size.y });

    ImDrawList_AddQuad(igGetWindowDrawList(), tl.add(screen_pos), tr.add(screen_pos), br.add(screen_pos), bl.add(screen_pos), color.value, thickness);
}

pub fn drawText(text: [*c]const u8, top_left: ImVec2) void {
    const tl = trans_mat.transformImVec2(top_left);
    ImDrawList_AddTextVec2(igGetWindowDrawList(), tl.add(screen_pos), 0xffffffff, text, null);
}

pub fn drawTex(texture: upaya.Texture, pos: ImVec2) void {
    const tl = trans_mat.transformImVec2(pos);
    var br = pos;
    br.x += @intToFloat(f32, texture.width);
    br.y += @intToFloat(f32, texture.height);
    br = trans_mat.transformImVec2(br);

    ImDrawList_AddImage(igGetWindowDrawList(), texture.imTextureID(), tl.add(screen_pos), br.add(screen_pos), .{}, .{ .x = 1, .y = 1 }, 0xffffffff);
}

pub fn drawTexPortion(texture: upaya.Texture, pos: ImVec2, rect: math.Rect) void {
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
