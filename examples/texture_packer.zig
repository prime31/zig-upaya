const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const colors = upaya.colors;
const fs = std.fs;
usingnamespace upaya.imgui;
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
    igSetNextWindowPos(.{}, ImGuiCond_Always, .{});
    igSetNextWindowSize(.{
        .x = @intToFloat(f32, upaya.sokol.sapp_width()),
        .y = @intToFloat(f32, upaya.sokol.sapp_height()),
    }, ImGuiCond_Always);

    if (igBegin("Main Window", null, ImGuiWindowFlags_NoTitleBar)) {
        if (atlas) |a| {
            igText("Atlas Size:");
            igSameLine(0, 5);

            igSetNextItemWidth(100);
            var tmp_size = [_]c_int{ @intCast(c_int, a.w), @intCast(c_int, a.h) };
            _ = igInputInt2("", &tmp_size, ImGuiInputTextFlags_None);
            igSameLine(0, 5);

            if (ogButton("Save to Desktop")) {
                const path_or_null = upaya.known_folders.getPath(upaya.mem.tmp_allocator, .desktop) catch unreachable;
                if (path_or_null) |path| atlas.?.save(path, "test");
            }

            if (igBeginChildEx("#child", 666, ogGetContentRegionAvail(), true, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_HorizontalScrollbar)) {
                var pos = ogGetCursorScreenPos();
                const size = ImVec2{ .x = @intToFloat(f32, a.w), .y = @intToFloat(f32, a.h) };

                ogAddRectFilled(igGetWindowDrawList(), pos, size, colors.rgbToU32(0, 0, 0));
                ogAddRect(igGetWindowDrawList(), pos, size, colors.rgbToU32(155, 0, 155), 1);
                _ = igInvisibleButton("##rects", size);

                for (a.rects) |rect| {
                    const tl = .{ .x = pos.x + @intToFloat(f32, rect.x), .y = pos.y + @intToFloat(f32, rect.y) };
                    ogAddRect(igGetWindowDrawList(), tl, .{ .x = @intToFloat(f32, rect.w), .y = @intToFloat(f32, rect.h) }, colors.rgbToU32(0, 255, 0), 1);
                    drawChunk(tl, rect.asRect());
                }
                igEndChild();
            }
        } else {
            var pos = ogGetCursorScreenPos();
            const size = ogGetContentRegionAvail();
            ogAddRectFilled(igGetWindowDrawList(), pos, size, colors.rgbToU32(80, 80, 80));

            var text_size: ImVec2 = undefined;
            igCalcTextSize(&text_size, "Drag/drop a folder", null, false, 1024);
            igSetCursorPos(.{ .x = (size.x / 2) - text_size.x, .y = size.y / 2 });

            igGetCurrentContext().FontSize *= 2;
            igText("Drag/drop a folder");
            igGetCurrentContext().FontSize /= 2;
        }
    }
    igEnd();
}

fn drawChunk(tl: ImVec2, rect: math.Rect) void {
    var br = tl;
    br.x += rect.w;
    br.y += rect.h;

    const inv_w = 1.0 / @intToFloat(f32, atlas.?.w);
    const inv_h = 1.0 / @intToFloat(f32, atlas.?.h);

    const uv0 = ImVec2{ .x = rect.x * inv_w, .y = rect.y * inv_h };
    const uv1 = ImVec2{ .x = (rect.x + rect.w) * inv_w, .y = (rect.y + rect.h) * inv_h };

    ImDrawList_AddImage(igGetWindowDrawList(), texture.?.imTextureID(), tl, br, uv0, uv1, 0xffffffff);
}

fn onFileDropped(file: []const u8) void {
    if (fs.cwd().openDir(file, .{ .iterate = true })) |dir| {
        atlas = upaya.TexturePacker.pack(file) catch unreachable;
        if (texture) |tex| tex.deinit();
        texture = atlas.?.image.asTexture(.nearest);
    } else |err| {
        std.debug.print("Dropped a non-directory: {}, err: {}\n", .{ file, err });
    }
}
