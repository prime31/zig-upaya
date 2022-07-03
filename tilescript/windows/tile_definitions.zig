const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
const imgui = @import("imgui");
const TileDefinitions = ts.data.TileDefinitions;

pub fn draw(state: *ts.AppState) void {
    if (state.prefs.windows.tile_definitions) {
        imgui.igSetNextWindowSize(.{ .x = 210, .y = -1 },  imgui.ImGuiCond_Always);
        if (imgui.igBegin("Tile Definitions", &state.prefs.windows.tile_definitions, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
            defer imgui.igEnd();

            inline for (@typeInfo(TileDefinitions).Struct.fields) |field, i| {
                imgui.igPushIDInt(@intCast(c_int, i));
                defer imgui.igPopID();

                drawTileIcon(field.name);

                imgui.igDummy(.{});
                imgui.igSameLine(0, imgui.igGetFrameHeight() + 7);

                // replace underscores with spaces
                var buffer = upaya.mem.tmp_allocator.alloc(u8, field.name.len) catch unreachable;
                for (field.name) |char, j| {
                    buffer[j] = if (char == '_') ' ' else char;
                }
                imgui.igAlignTextToFramePadding();
                imgui.igText(buffer.ptr);

                imgui.igSameLine(0, 0);
                imgui.igSetCursorPosX(imgui.igGetWindowContentRegionWidth() - 35);

                if (imgui.ogButton("Tiles")) {
                    imgui.igOpenPopup("tag-tiles");
                }

                imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
                if (imgui.igBeginPopup("tag-tiles", imgui.ImGuiWindowFlags_None)) {
                    defer imgui.igEndPopup();
                    var list = &@field(state.map.tile_definitions, field.name);
                    tileSelectorPopup(state, list);
                }
            }
        }
    }
}

fn drawTileIcon(comptime name: []const u8) void {
    var tl = imgui.ogGetCursorScreenPos();
    var tr = tl;
    tr.x += imgui.igGetFrameHeight();
    var bl = tl;
    bl.y += imgui.igGetFrameHeight();
    var br = bl;
    br.x += imgui.igGetFrameHeight();

    var color = ts.colors.colorRgb(252, 186, 3);

    if (std.mem.eql(u8, name, "solid")) {
        imgui.ImDrawList_AddQuadFilled(imgui.igGetWindowDrawList(), tl, tr, br, bl, color);
    } else if (std.mem.eql(u8, name, "slope_down")) {
        tl.y += imgui.igGetFrameHeight() / 2;
        imgui.ImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), tl, bl, br, color);
    } else if (std.mem.eql(u8, name, "slope_down_steep")) {
        imgui.ImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), tl, bl, br, color);
    } else if (std.mem.eql(u8, name, "slope_up")) {
        tr.y += imgui.igGetFrameHeight() / 2;
        imgui.ImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), bl, br, tr, color);
    } else if (std.mem.eql(u8, name, "slope_up_steep")) {
        imgui.ImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), bl, br, tr, color);
    }
}

fn tileSelectorPopup(state: *ts.AppState, list: anytype) void {
    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    const tile_spacing = state.map.tile_spacing * zoom;
    const tile_size = state.map.tile_size * zoom;

    imgui.ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    // draw selected tiles
    var iter = list.iter();
    while (iter.next()) |value| {
        ts.addTileToDrawList(tile_size, content_start_pos, value, state.tilesPerRow(), tile_spacing);
    }

    // check input for toggling state
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(0, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            TileDefinitions.toggleSelected(list, @intCast(u8, tile.x + tile.y * state.tilesPerRow()));
        }
    }

    if (imgui.igButton("Clear", .{ .x = -1 })) {
        list.clear();
    }
}
