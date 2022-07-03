const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const colors = upaya.colors;
const fs = std.fs;
const imgui = upaya.imgui;
const stb = @import("stb");

var atlas: ?upaya.TexturePacker.Atlas = null;
var texture: ?upaya.Texture = null;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .shutdown = shutdown,
        .docking = false,
        .width = 1024,
        .height = 768,
        .window_title = "Texture Packer",
        .onFileDropped = onFileDropped,
    });
}

fn init() void {}

fn shutdown() void {
    if (atlas) |a| a.deinit();
}

fn update() void {
    imgui.ogSetNextWindowPos(.{},  imgui.ImGuiCond_Always, .{});
    imgui.ogSetNextWindowSize(.{
        .x = @intToFloat(f32, upaya.sokol.sapp_width()),
        .y = @intToFloat(f32, upaya.sokol.sapp_height()),
    },  imgui.ImGuiCond_Always);

    if (imgui.igBegin("Main Window", null, imgui.ImGuiWindowFlags_NoTitleBar)) {
        if (atlas) |a| {
            imgui.igText("Atlas Size:");
            imgui.igSameLine(0, 5);

            imgui.igSetNextItemWidth(100);
            var tmp_size = [_]c_int{ @intCast(c_int, a.w), @intCast(c_int, a.h) };
            _ = imgui.igInputInt2("", &tmp_size, imgui.ImGuiInputTextFlags_None);
            imgui.igSameLine(0, 5);

            if (imgui.ogButton("Save to Desktop")) {
                const path_or_null = upaya.known_folders.getPath(upaya.mem.tmp_allocator, .desktop) catch unreachable;
                if (path_or_null) |path| atlas.?.save(path, "test");
            }

            defer imgui.igEndChild();
            if (imgui.ogBeginChildEx("#child", 666, imgui.ogGetContentRegionAvail(), true, imgui.ImGuiWindowFlags_NoTitleBar | imgui.ImGuiWindowFlags_HorizontalScrollbar)) {
                var pos = imgui.ogGetCursorScreenPos();
                const size = imgui.ImVec2{ .x = @intToFloat(f32, a.w), .y = @intToFloat(f32, a.h) };

                imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), pos, size, colors.rgbToU32(0, 0, 0));
                imgui.ogAddRect(imgui.igGetWindowDrawList(), pos, size, colors.rgbToU32(155, 0, 155), 1);
                _ = imgui.ogInvisibleButton("##rects", size, imgui.ImGuiButtonFlags_None);

                for (a.rects) |rect| {
                    const tl = .{ .x = pos.x + @intToFloat(f32, rect.x), .y = pos.y + @intToFloat(f32, rect.y) };
                    imgui.ogAddRect(imgui.igGetWindowDrawList(), tl, .{ .x = @intToFloat(f32, rect.w), .y = @intToFloat(f32, rect.h) }, colors.rgbToU32(0, 255, 0), 1);
                    drawChunk(tl, rect.asRect());
                }
            }
        } else {
            var pos = imgui.ogGetCursorScreenPos();
            const size = imgui.ogGetContentRegionAvail();
            imgui.ogAddRectFilled(imgui.igGetWindowDrawList(), pos, size, colors.rgbToU32(80, 80, 80));

            var text_size: imgui.ImVec2 = undefined;
            imgui.igCalcTextSize(&text_size, "Drag/drop a folder", null, false, 1024);
            imgui.ogSetCursorPos(.{ .x = (size.x / 2) - text_size.x, .y = size.y / 2 });

            imgui.igGetCurrentContext().FontSize *= 2;
            imgui.igText("Drag/drop a folder");
            imgui.igGetCurrentContext().FontSize /= 2;
        }
    }
    imgui.igEnd();
}

fn drawChunk(tl: imgui.ImVec2, rect: math.Rect) void {
    var br = tl;
    br.x += rect.w;
    br.y += rect.h;

    const inv_w = 1.0 / @intToFloat(f32, atlas.?.w);
    const inv_h = 1.0 / @intToFloat(f32, atlas.?.h);

    const uv0 = imgui.ImVec2{ .x = rect.x * inv_w, .y = rect.y * inv_h };
    const uv1 = imgui.ImVec2{ .x = (rect.x + rect.w) * inv_w, .y = (rect.y + rect.h) * inv_h };

    imgui.ogImDrawList_AddImage(imgui.igGetWindowDrawList(), texture.?.imTextureID(), tl, br, uv0, uv1, 0xFFFFFFFF);

}

fn onFileDropped(file: []const u8) void {
    if (fs.cwd().openDir(file, .{ .iterate = true })) {
        atlas = upaya.TexturePacker.pack(file) catch unreachable;
        if (texture) |tex| tex.deinit();
        texture = atlas.?.image.asTexture(.nearest);
    } else |err| {
        std.debug.print("Dropped a non-directory: {s}, err: {}\n", .{ file, err });
    }
}
