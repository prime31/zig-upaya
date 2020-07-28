const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
usingnamespace @import("imgui");

pub fn draw(state: *ts.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, .{ .x = 220, .y = 100 });
    defer igPopStyleVar(1);

    if (state.prefs.windows.tags) {
        if (igBegin("Tags", &state.prefs.windows.tags, ImGuiWindowFlags_None)) {
            defer igEnd();

            if (igBeginChildEx("##tag-child", igGetItemID(), .{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
                defer igEndChild();

                var delete_index: usize = std.math.maxInt(usize);
                for (state.map.tags.items) |*tag, i| {
                    igPushIDInt(@intCast(c_int, i));

                    if (ogInputText("##key", &tag.name, tag.name.len)) {}
                    igSameLine(0, 5);

                    igPushItemWidth(100);
                    if (ogButton("Tiles")) {
                        igOpenPopup("tag-tiles");
                    }
                    igPopItemWidth();

                    igSameLine(igGetWindowContentRegionWidth() - 20, 0);
                    if (ogButton(icons.trash)) {
                        delete_index = i;
                    }

                    igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
                    if (igBeginPopup("tag-tiles", ImGuiWindowFlags_None)) {
                        defer igEndPopup();
                        tagTileSelectorPopup(state, tag);
                    }

                    igPopID();
                }

                if (delete_index < std.math.maxInt(usize)) {
                    _ = state.map.tags.orderedRemove(delete_index);
                }
            }

            if (igButton("Add Tag", .{})) {
                state.map.addTag();
            }
        }
    }
}

fn tagTileSelectorPopup(state: *ts.AppState, tag: *ts.data.Tag) void {
    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    const tile_spacing = state.map.tile_spacing * zoom;
    const tile_size = state.map.tile_size * zoom;

    ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    const draw_list = igGetWindowDrawList();

    // draw selected tiles
    var iter = tag.tiles.iter();
    while (iter.next()) |value| {
        ts.addTileToDrawList(tile_size, content_start_pos, value, state.tilesPerRow(), tile_spacing);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            tag.toggleSelected(@intCast(u8, tile.x + tile.y * state.tilesPerRow()));
        }
    }

    if (igButton("Clear", ImVec2{ .x = -1 })) {
        tag.tiles.clear();
    }
}
