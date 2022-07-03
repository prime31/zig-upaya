const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
const imgui = @import("imgui");

pub fn draw(state: *ts.AppState) void {
    imgui.igPushStyleVarVec2(imgui.ImGuiStyleVar_WindowMinSize, .{ .x = 220, .y = 100 });
    defer imgui.igPopStyleVar(1);

    if (state.prefs.windows.tags) {
        if (imgui.igBegin("Tags", &state.prefs.windows.tags, imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEnd();

            if (imgui.igBeginChildEx("##tag-child", imgui.igGetItemID(), .{ .y = -imgui.igGetFrameHeightWithSpacing() }, false, imgui.ImGuiWindowFlags_None)) {
                defer imgui.igEndChild();

                var delete_index: usize = std.math.maxInt(usize);
                for (state.map.tags.items) |*tag, i| {
                    imgui.igPushIDInt(@intCast(c_int, i));

                    if (imgui.ogInputText("##key", &tag.name, tag.name.len)) {}
                    imgui.igSameLine(0, 5);

                    imgui.igPushItemWidth(100);
                    if (imgui.ogButton("Tiles")) {
                        imgui.igOpenPopup("tag-tiles");
                    }
                    imgui.igPopItemWidth();

                    imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 20, 0);
                    if (imgui.ogButton(imgui.icons.trash)) {
                        delete_index = i;
                    }

                    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
                    if (imgui.igBeginPopup("tag-tiles", imgui.ImGuiWindowFlags_None)) {
                        defer imgui.igEndPopup();
                        tagTileSelectorPopup(state, tag);
                    }

                    imgui.igPopID();
                }

                if (delete_index < std.math.maxInt(usize)) {
                    _ = state.map.tags.orderedRemove(delete_index);
                }
            }

            if (imgui.igButton("Add Tag", .{})) {
                state.map.addTag();
            }
        }
    }
}

fn tagTileSelectorPopup(state: *ts.AppState, tag: *ts.data.Tag) void {
    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    const tile_spacing = state.map.tile_spacing * zoom;
    const tile_size = state.map.tile_size * zoom;

    imgui.ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    // draw selected tiles
    var iter = tag.tiles.iter();
    while (iter.next()) |value| {
        ts.addTileToDrawList(tile_size, content_start_pos, value, state.tilesPerRow(), tile_spacing);
    }

    // check input for toggling state
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(0, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            tag.toggleSelected(@intCast(u8, tile.x + tile.y * state.tilesPerRow()));
        }
    }

    if (imgui.igButton("Clear", imgui.ImVec2{ .x = -1 })) {
        tag.tiles.clear();
    }
}
