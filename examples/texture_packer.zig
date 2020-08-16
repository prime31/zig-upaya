const std = @import("std");
const upaya = @import("upaya");
const colors = upaya.colors;
usingnamespace upaya.imgui;
const stb = @import("stb");

var rects: []stb.stbrp_rect = undefined;
var rect_count: usize = 20;
var last_pack_result = true;
const heuristics = [_][]const u8{ "Skyline", "Skyline BF" };
var heuristic: usize = 0;
const tex_sizes = [_][]const u8{ "256", "512", "1024", "2048", "4096" };
var tex_size_index: usize = 2;
var tex_size: c_int = 1024;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {
    rects = upaya.mem.allocator.alloc(stb.stbrp_rect, rect_count) catch unreachable;
    regenerateRects();
    solve();
}

fn update() void {
    igSetNextWindowPos(.{}, ImGuiCond_Always, .{});
    igSetNextWindowSize(.{
        .x = @intToFloat(f32, upaya.sokol.sapp_width()),
        .y = @intToFloat(f32, upaya.sokol.sapp_height()),
    }, ImGuiCond_Always);

    if (igBegin("My First Window", null, ImGuiWindowFlags_NoTitleBar)) {
        igSetNextItemWidth(100);
        if (igBeginCombo("Heuristic", heuristics[heuristic].ptr, ImGuiComboFlags_None)) {
            for (heuristics) |h, i| {
                if (igSelectableBool(heuristics[i].ptr, i == heuristic, ImGuiSelectableFlags_None, .{})) {
                    heuristic = i;
                    solve();
                }
            }
            igEndCombo();
        }
        igSameLine(0, 15);

        igSetNextItemWidth(100);
        if (igBeginCombo("Tex Size", tex_sizes[tex_size_index].ptr, ImGuiComboFlags_None)) {
            for (tex_sizes) |h, i| {
                if (igSelectableBool(h.ptr, i == tex_size_index, ImGuiSelectableFlags_None, .{})) {
                    tex_size_index = i;
                    switch (i) {
                        0 => tex_size = 256,
                        1 => tex_size = 512,
                        2 => tex_size = 1024,
                        3 => tex_size = 2048,
                        4 => tex_size = 4096,
                        else => {},
                    }
                    solve();
                }
            }
            igEndCombo();
        }
        igSameLine(0, 15);

        igSetNextItemWidth(100);
        if (ogDrag(usize, "Total Rects", &rect_count, 0.4, 2, 300)) {
            upaya.mem.allocator.free(rects);
            rects = upaya.mem.allocator.alloc(stb.stbrp_rect, rect_count) catch unreachable;
            regenerateRects();
            solve();
        }

        igSameLine(0, 50);
        if (ogButton("Regenerate Rects")) {
            regenerateRects();
            solve();
        }

        if (igBeginChildEx("#child", 666, ogGetContentRegionAvail(), true, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_HorizontalScrollbar)) {
            var pos = ogGetCursorScreenPos();
            const size = @intToFloat(f32, tex_size);
            ogAddRectFilled(igGetWindowDrawList(), pos, .{ .x = size, .y = size }, colors.rgbToU32(20, 20, 20));
            _ = igInvisibleButton("##rects", .{ .x = size, .y = size });

            const color = if (last_pack_result) colors.rgbToU32(0, 255, 0) else colors.rgbToU32(255, 0, 0);
            for (rects) |rect| {
                if (rect.was_packed == 0) continue;
                const tl = .{ .x = pos.x + @intToFloat(f32, rect.x), .y = pos.y + @intToFloat(f32, rect.y) };
                ogAddRect(igGetWindowDrawList(), tl, .{ .x = @intToFloat(f32, rect.w), .y = @intToFloat(f32, rect.h) }, color, 1);
            }
            igEndChild();
        }
    }
    igEnd();
}

fn solve() void {
    var ctx: stb.stbrp_context = undefined;
    const rects_size = @sizeOf(stb.stbrp_rect) * rects.len;
    const node_count = 4096 * 2;
    var nodes: [node_count]stb.stbrp_node = undefined;

    stb.stbrp_init_target(&ctx, tex_size, tex_size, &nodes, node_count);
    stb.stbrp_setup_heuristic(&ctx, @intCast(c_int, heuristic));
    last_pack_result = stb.stbrp_pack_rects(&ctx, rects.ptr, @intCast(c_int, rects.len)) == 1;
}

fn regenerateRects() void {
    var i: c_int = 0;
    while (i < rects.len) : (i += 1) {
        rects[@intCast(usize, i)] = .{
            .id = i,
            .x = 0,
            .y = 0,
            .w = upaya.math.rand.range(c_ushort, 50, 300),
            .h = upaya.math.rand.range(c_ushort, 50, 300),
        };
    }
}
