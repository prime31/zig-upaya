const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
usingnamespace @import("imgui");
const TileDefinitions = ts.data.TileDefinitions;

pub fn draw(state: *ts.AppState) void {
    if (state.prefs.windows.tile_definitions) {
        igSetNextWindowSize(.{ .x = 210, .y = -1 }, ImGuiCond_Always);
        if (igBegin("Tile Definitions", &state.prefs.windows.tile_definitions, ImGuiWindowFlags_AlwaysAutoResize)) {
            defer igEnd();

            inline for (@typeInfo(TileDefinitions).Struct.fields) |field, i| {
                igPushIDInt(@intCast(c_int, i));
                defer igPopID();

                drawTileIcon(field.name);

                igDummy(.{});
                igSameLine(0, igGetFrameHeight() + 7);

                // replace underscores with spaces
                var buffer = upaya.mem.tmp_allocator.alloc(u8, field.name.len) catch unreachable;
                for (field.name) |char, j| {
                    buffer[j] = if (char == '_') ' ' else char;
                }
                igAlignTextToFramePadding();
                igText(buffer.ptr);

                igSameLine(0, 0);
                igSetCursorPosX(igGetWindowContentRegionWidth() - 35);

                if (ogButton("Tiles")) {
                    igOpenPopup("tag-tiles");
                }

                igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
                if (igBeginPopup("tag-tiles", ImGuiWindowFlags_None)) {
                    defer igEndPopup();
                    var list = &@field(state.map.tile_definitions, field.name);
                    tileSelectorPopup(state, list);
                }
            }
        }
    }
}

fn drawTileIcon(comptime name: []const u8) void {
    var tl = ogGetCursorScreenPos();
    var tr = tl;
    tr.x += igGetFrameHeight();
    var bl = tl;
    bl.y += igGetFrameHeight();
    var br = bl;
    br.x += igGetFrameHeight();

    var color = ts.colors.colorRgb(252, 186, 3);

    if (std.mem.eql(u8, name, "solid")) {
        ImDrawList_AddQuadFilled(igGetWindowDrawList(), tl, tr, br, bl, color);
    } else if (std.mem.eql(u8, name, "slope_down")) {
        tl.y += igGetFrameHeight() / 2;
        ImDrawList_AddTriangleFilled(igGetWindowDrawList(), tl, bl, br, color);
    } else if (std.mem.eql(u8, name, "slope_down_steep")) {
        ImDrawList_AddTriangleFilled(igGetWindowDrawList(), tl, bl, br, color);
    } else if (std.mem.eql(u8, name, "slope_up")) {
        tr.y += igGetFrameHeight() / 2;
        ImDrawList_AddTriangleFilled(igGetWindowDrawList(), bl, br, tr, color);
    } else if (std.mem.eql(u8, name, "slope_up_steep")) {
        ImDrawList_AddTriangleFilled(igGetWindowDrawList(), bl, br, tr, color);
    }
}

fn tileSelectorPopup(state: *ts.AppState, list: anytype) void {
    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    const tile_spacing = state.map.tile_spacing * zoom;
    const tile_size = state.map.tile_size * zoom;

    ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    const draw_list = igGetWindowDrawList();

    // draw selected tiles
    var iter = list.iter();
    while (iter.next()) |value| {
        ts.addTileToDrawList(tile_size, content_start_pos, value, state.tilesPerRow(), tile_spacing);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            TileDefinitions.toggleSelected(list, @intCast(u8, tile.x + tile.y * state.tilesPerRow()));
        }
    }

    if (igButton("Clear", .{ .x = -1 })) {
        list.clear();
    }
}
