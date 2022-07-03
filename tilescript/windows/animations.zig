const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
const imgui = @import("imgui");
const brushes_win = @import("brushes.zig");

var buffer: [25]u8 = undefined;

pub fn draw(state: *ts.AppState) void {
    imgui.igPushStyleVarVec2(imgui.ImGuiStyleVar_WindowMinSize, imgui.ImVec2{ .x = 200, .y = 200 });
    defer imgui.igPopStyleVar(1);

    if (state.prefs.windows.animations and imgui.igBegin("Animations", &state.prefs.windows.animations, imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEnd();

        if (imgui.igBeginChildEx("##animations-child", imgui.igGetItemID(), imgui.ImVec2{ .y = -imgui.igGetFrameHeightWithSpacing() }, false, imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndChild();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.animations.items) |*anim, i| {
                imgui.igPushIDInt(@intCast(c_int, i));

                if (ts.tileImageButton(state, 16, anim.tile)) {
                    imgui.igOpenPopup("tile-chooser");
                }
                imgui.igSameLine(0, 5);

                if (imgui.ogButton("Tiles")) {
                    imgui.igOpenPopup("animation-tiles");
                }
                imgui.igSameLine(0, 5);

                imgui.igPushItemWidth(75);
                _=  imgui.ogDragUnsignedFormat(u16, "", &anim.rate, 1, 0, std.math.maxInt(u16), "%dms");
                imgui.igPopItemWidth();
                imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 20, 0);

                if (imgui.ogButton(imgui.icons.trash)) {
                    delete_index = i;
                }

                imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
                if (imgui.igBeginPopup("tile-chooser", imgui.ImGuiWindowFlags_None)) {
                    animTileSelectorPopup(state, anim, .single);
                    imgui.igEndPopup();
                }

                imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
                if (imgui.igBeginPopup("animation-tiles", imgui.ImGuiWindowFlags_None)) {
                    animTileSelectorPopup(state, anim, .multi);
                    imgui.igEndPopup();
                }

                imgui.igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                _ = state.map.animations.orderedRemove(delete_index);
            }
        }

        if (imgui.igButton("Add Animation", imgui.ImVec2{})) {
            imgui.igOpenPopup("add-anim");
        }

        imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("add-anim", imgui.ImGuiWindowFlags_None)) {
            addAnimationPopup(state);
            imgui.igEndPopup();
        }
    }
}

fn addAnimationPopup(state: *ts.AppState) void {
    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    imgui.ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, state.map.tile_size * zoom), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * state.tilesPerRow());
            state.map.addAnimation(tile_index);
            imgui.igCloseCurrentPopup();
        }
    }
}

fn animTileSelectorPopup(state: *ts.AppState, anim: *ts.data.Animation, selection_type: enum { single, multi }) void {
    const per_row = state.tilesPerRow();

    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    const tile_spacing = state.map.tile_spacing * zoom;
    const tile_size = state.map.tile_size * zoom;

    imgui.ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    // draw selected tile or tiles
    if (selection_type == .multi) {
        var iter = anim.tiles.iter();
        while (iter.next()) |value| {
            ts.addTileToDrawList(tile_size, content_start_pos, value, per_row, tile_spacing);
        }
    } else {
        ts.addTileToDrawList(tile_size, content_start_pos, anim.tile, per_row, tile_spacing);
    }

    // check input for toggling state
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * per_row);
            if (selection_type == .multi) {
                anim.toggleSelected(tile_index);
            } else {
                anim.tile = tile_index;
                imgui.igCloseCurrentPopup();
            }
        }
    }

    if (selection_type == .multi and imgui.igButton("Clear", imgui.ImVec2{ .x = -1 })) {
        anim.tiles.clear();
    }
}
