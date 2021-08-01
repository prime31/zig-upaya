const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
usingnamespace @import("imgui");
const brushes_win = @import("brushes.zig");

var buffer: [25]u8 = undefined;

pub fn draw(state: *ts.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 200 });
    defer igPopStyleVar(1);

    if (state.prefs.windows.animations and igBegin("Animations", &state.prefs.windows.animations, ImGuiWindowFlags_None)) {
        defer igEnd();

        if (igBeginChildEx("##animations-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.animations.items) |*anim, i| {
                igPushIDInt(@intCast(c_int, i));

                if (ts.tileImageButton(state, 16, anim.tile)) {
                    igOpenPopup("tile-chooser");
                }
                igSameLine(0, 5);

                if (ogButton("Tiles")) {
                    igOpenPopup("animation-tiles");
                }
                igSameLine(0, 5);

                igPushItemWidth(75);
                _ = ogDragUnsignedFormat(u16, "", &anim.rate, 1, 0, std.math.maxInt(u16), "%dms");
                igPopItemWidth();
                igSameLine(igGetWindowContentRegionWidth() - 20, 0);

                if (ogButton(icons.trash)) {
                    delete_index = i;
                }

                igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
                if (igBeginPopup("tile-chooser", ImGuiWindowFlags_None)) {
                    animTileSelectorPopup(state, anim, .single);
                    igEndPopup();
                }

                igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
                if (igBeginPopup("animation-tiles", ImGuiWindowFlags_None)) {
                    animTileSelectorPopup(state, anim, .multi);
                    igEndPopup();
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                _ = state.map.animations.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Animation", ImVec2{})) {
            igOpenPopup("add-anim");
        }

        igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("add-anim", ImGuiWindowFlags_None)) {
            addAnimationPopup(state);
            igEndPopup();
        }
    }
}

fn addAnimationPopup(state: *ts.AppState) void {
    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, state.map.tile_size * zoom), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * state.tilesPerRow());
            state.map.addAnimation(tile_index);
            igCloseCurrentPopup();
        }
    }
}

fn animTileSelectorPopup(state: *ts.AppState, anim: *ts.data.Animation, selection_type: enum { single, multi }) void {
    const per_row = state.tilesPerRow();

    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (state.texture.width < 200 and state.texture.height < 200) 2 else 1;
    const tile_spacing = state.map.tile_spacing * zoom;
    const tile_size = state.map.tile_size * zoom;

    ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));

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
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * per_row);
            if (selection_type == .multi) {
                anim.toggleSelected(tile_index);
            } else {
                anim.tile = tile_index;
                igCloseCurrentPopup();
            }
        }
    }

    if (selection_type == .multi and igButton("Clear", ImVec2{ .x = -1 })) {
        anim.tiles.clear();
    }
}
