const std = @import("std");
usingnamespace @import("imgui");

const ts = @import("tilescript.zig");
const upaya = @import("upaya");
const files = @import("filebrowser");
const stb = @import("stb");

// used to fill the ui while we are getting input for loading/resizing
var temp_state = struct {
    tile_size: usize = 16,
    tile_spacing: usize = 0,
    map_width: usize = 64,
    map_height: usize = 64,
    has_image: bool = false,
    invalid_image_selected: bool = false,
    error_loading_file: bool = false,
    image: [255:0]u8 = undefined,
    show_load_tileset_popup: bool = false,

    pub fn reset(self: *@This()) void {
        self.tile_size = 16;
        self.tile_spacing = 0;
        self.map_width = 64;
        self.map_height = 64;
        self.has_image = false;
        self.invalid_image_selected = false;
        self.error_loading_file = false;
        std.mem.set(u8, &self.image, 0);
    }
}{};

fn checkKeyboardShortcuts(state: *ts.AppState) void {
    // shortcuts for pressing 1-9 to set the brush
    var key: usize = 49;
    while (key < 58) : (key += 1) {
        if (ogKeyPressed(key)) state.selected_brush_index = @intCast(usize, key - 49);
    }

    // show the quick brush selector
    // TODO: this igIsPopupOpenStr doesnt work
    // if (!igIsPopupOpenStr("##pattern_popup")) {
    //     if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_B)) {
    //         igOpenPopup("##brushes-root");
    //     }
    // }

    // undo/redo
    if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_Z) and (igGetIO().KeySuper or igGetIO().KeyCtrl) and igGetIO().KeyShift) {
        ts.history.redo();
        state.map_data_dirty = true;
    } else if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_Z) and (igGetIO().KeySuper or igGetIO().KeyCtrl)) {
        ts.history.undo();
        state.map_data_dirty = true;
    }

    // help
    if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_SLASH) and igGetIO().KeyShift) {
        igOpenPopup("Help");
    }

    // zoom in/out
    if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_UP)) {
        if (state.prefs.tile_size_multiplier < 4) {
            state.prefs.tile_size_multiplier += 1;
        }
    }
    if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_DOWN)) {
        if (state.prefs.tile_size_multiplier > 1) {
            state.prefs.tile_size_multiplier -= 1;
        }
    }
    state.map_rect_size = @intToFloat(f32, state.map.tile_size * state.prefs.tile_size_multiplier);

    if (ogKeyPressed(upaya.sokol.SAPP_KEYCODE_TAB)) {
        state.toggleEditMode();
    }
}

fn getDefaultPath() [:0]const u8 {
    const path_or_null = @import("known-folders.zig").getPath(upaya.mem.tmp_allocator, .desktop) catch unreachable;
    const tmp_path = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, std.fs.path.sep_str }) catch unreachable;
    return std.mem.dupeZ(upaya.mem.tmp_allocator, u8, tmp_path) catch unreachable;
}

pub fn draw(state: *ts.AppState) void {
    checkKeyboardShortcuts(state);

    var show_load_tileset_popup = false;
    var show_resize_popup = false;
    var show_help_popup = false;

    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New", null, false, true)) {
                // TODO: fix loading of map getting wrong margin/size/tiles-per-row or something...
                @import("windows/object_editor.zig").setSelectedObject(null);
                const tile_size = state.map.tile_size;
                const tile_spacing = state.map.tile_spacing;

                state.map.deinit();
                state.map = ts.Map.init(tile_size, tile_spacing);
                state.clearQuickFile(.opened);
                state.clearQuickFile(.exported);
                state.resizeMap(state.map.w, state.map.h);
            }

            if (igMenuItemBool("Open...", null, false, true)) {
                const res = files.openFileDialog("Open project", getDefaultPath(), "*.ts");
                if (res != null) {
                    state.loadMap(std.mem.spanZ(res)) catch |err| {
                        state.showToast("Error loading map. Could not find tileset image.", 300);
                    };
                }
            }

            if (igMenuItemBool("Save", null, false, state.opened_file != null)) {
                state.saveMap(state.opened_file.?) catch unreachable;
            }

            if (igMenuItemBool("Save As...", null, false, true)) {
                if (state.map.image.len == 0) {
                    state.showToast("No tileset image has been selected.\nLoad a tileset image before saving.", 200);
                    return;
                }

                const res = files.saveFileDialog("Save project", getDefaultPath(), "*.ts");
                if (res != null) {
                    var out_file = res[0..std.mem.lenZ(res)];
                    if (!std.mem.endsWith(u8, out_file, ".ts")) {
                        out_file = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ out_file, ".ts" }) catch unreachable;
                    }

                    // validate our image path and copy the image to our save dir if its absolute
                    if (std.fs.path.isAbsolute(state.map.image)) {
                        const my_cwd = std.fs.cwd();
                        const dst_dir = std.fs.cwd().openDir(std.fs.path.dirname(out_file).?, .{}) catch unreachable;
                        const image_name = std.fs.path.basename(state.map.image);
                        std.fs.Dir.copyFile(my_cwd, state.map.image, dst_dir, image_name, .{}) catch |err| {
                            std.debug.print("error copying tileset file: {}\n", .{err});
                        };

                        // dupe the image before we free it
                        const duped_image_name = upaya.mem.allocator.dupe(u8, image_name) catch unreachable;
                        upaya.mem.allocator.free(state.map.image);
                        state.map.image = duped_image_name;
                    }

                    state.saveMap(out_file) catch unreachable;

                    // store the filename so we can do direct saves later
                    state.clearQuickFile(.opened);
                    state.opened_file = upaya.mem.allocator.dupe(u8, out_file) catch unreachable;
                }
            }

            igSeparator();

            if (igBeginMenu("Export", true)) {
                defer igEndMenu();

                if (igMenuItemBool("Quick JSON Export", null, false, state.exported_file != null)) {
                    state.exportJson(state.exported_file.?) catch unreachable;
                }

                if (igMenuItemBool("JSON...", null, false, true)) {
                    const res = files.saveFileDialog("Export to JSON", getDefaultPath(), "*.json");
                    if (res != null) {
                        var out_file = res[0..std.mem.lenZ(res)];
                        if (!std.mem.endsWith(u8, out_file, ".json")) {
                            out_file = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ out_file, ".json" }) catch unreachable;
                        }

                        state.exportJson(out_file) catch unreachable;

                        // store the filename so we can do quick exports later
                        state.clearQuickFile(.exported);
                        state.exported_file = upaya.mem.allocator.dupe(u8, out_file) catch unreachable;
                    }
                }

                if (igMenuItemBool("Binary...", null, false, true)) {
                    state.showToast("Doesn't work yet...", 100);
                }

                if (igMenuItemBool("Tiled...", null, false, true)) {
                    const res = files.saveFileDialog("Export to Tiled", getDefaultPath(), "*.json");
                    if (res != null) {
                        var out_file = res[0..std.mem.lenZ(res)];
                        if (!std.mem.endsWith(u8, out_file, ".json")) {
                            out_file = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ out_file, ".json" }) catch unreachable;
                        }

                        @import("persistence.zig").exportTiled(state, out_file) catch unreachable;
                    }
                }
            }
        }

        if (igBeginMenu("Map", true)) {
            defer igEndMenu();

            show_load_tileset_popup = igMenuItemBool("Load Tileset", null, false, true);
            show_resize_popup = igMenuItemBool("Resize Map", null, false, true);
        }

        if (igBeginMenu("View", true)) {
            defer igEndMenu();

            _ = igMenuItemBoolPtr("Objects", null, &state.prefs.windows.objects, true);
            _ = igMenuItemBoolPtr("Tags", null, &state.prefs.windows.tags, true);
            _ = igMenuItemBoolPtr("Tile Definitions", null, &state.prefs.windows.tile_definitions, true);
            _ = igMenuItemBoolPtr("Animations", null, &state.prefs.windows.animations, true);
            _ = igMenuItemBoolPtr("Post Processed Map", null, &state.prefs.windows.post_processed_map, true);
        }

        if (igBeginMenu("Settings", true)) {
            defer igEndMenu();

            if (igBeginMenu("Map Display Size", true)) {
                defer igEndMenu();

                if (igMenuItemBool("1x", null, state.prefs.tile_size_multiplier == 1, true)) {
                    state.prefs.tile_size_multiplier = 1;
                    state.map_rect_size = @intToFloat(f32, state.map.tile_size);
                }
                if (igMenuItemBool("2x", null, state.prefs.tile_size_multiplier == 2, true)) {
                    state.prefs.tile_size_multiplier = 2;
                    state.map_rect_size = @intToFloat(f32, state.map.tile_size * 2);
                }
                if (igMenuItemBool("3x", null, state.prefs.tile_size_multiplier == 3, true)) {
                    state.prefs.tile_size_multiplier = 3;
                    state.map_rect_size = @intToFloat(f32, state.map.tile_size * 3);
                }
                if (igMenuItemBool("4x", null, state.prefs.tile_size_multiplier == 4, true)) {
                    state.prefs.tile_size_multiplier = 4;
                    state.map_rect_size = @intToFloat(f32, state.map.tile_size * 4);
                }
            }

            _ = igMenuItemBoolPtr("Show Animations", null, &state.prefs.show_animations, true);
            _ = igMenuItemBoolPtr("Show Objects", null, &state.prefs.show_objects, true);

            if (igColorEdit3("UI Tint Color", &ts.colors.ui_tint.x, ImGuiColorEditFlags_NoInputs)) {
                ts.colors.setTintColor(ts.colors.ui_tint);
            }
        }

        if (igBeginMenu("Help", true)) {
            show_help_popup = true;
            igEndMenu();
        }

        const buttom_margin: f32 = if (state.object_edit_mode) 88 else 75;
        igSetCursorPosX(igGetWindowWidth() - buttom_margin);
        if (ogButton(if (state.object_edit_mode) "Object Mode" else "Tile Mode")) {
            state.toggleEditMode();
        }
    }

    // handle popups in the same scope
    if (show_load_tileset_popup) {
        temp_state.reset();
        igOpenPopup("Load Tileset");
    }

    if (show_help_popup) {
        igOpenPopup("Help");
    }

    // handle a dragged-in file
    if (temp_state.show_load_tileset_popup) {
        temp_state.show_load_tileset_popup = false;
        igOpenPopup("Load Tileset");
    }

    if (show_resize_popup) {
        temp_state.reset();
        temp_state.map_width = state.map.w;
        temp_state.map_height = state.map.h;
        igOpenPopup("Resize Map");
    }

    loadTilesetPopup(state);
    resizeMapPopup(state);
    helpPopup();
}

/// sets the file in our state and triggers the load-tileset popup to be shown
pub fn loadTileset(file: []const u8) void {
    temp_state.reset();
    temp_state.has_image = true;
    temp_state.show_load_tileset_popup = true;
    std.mem.copy(u8, &temp_state.image, file);
}

fn loadTilesetPopup(state: *ts.AppState) void {
    if (igBeginPopupModal("Load Tileset", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        if (temp_state.has_image) {
            // only display the filename here (not the full path) so there is room for the button
            const last_sep = std.mem.lastIndexOf(u8, &temp_state.image, std.fs.path.sep_str) orelse 0;
            const sentinel_index = std.mem.indexOfScalar(u8, &temp_state.image, 0) orelse temp_state.image.len;
            const c_file = std.cstr.addNullByte(upaya.mem.tmp_allocator, temp_state.image[last_sep + 1 .. sentinel_index]) catch unreachable;
            igText(c_file);
        }
        igSameLine(0, 5);

        if (igButton("Choose", ImVec2{ .x = -1, .y = 0 })) {
            const desktop = getDefaultPath();

            const res = files.openFileDialog("Import tileset image", desktop, "*.png");
            if (res != null) {
                std.mem.copy(u8, &temp_state.image, std.mem.spanZ(res));
                temp_state.has_image = true;
            } else {
                temp_state.has_image = false;
            }
        }

        _ = ogDrag(usize, "Tile Size", &temp_state.tile_size, 0.1, 8, 32);
        _ = ogDrag(usize, "Tile Spacing", &temp_state.tile_spacing, 0.1, 0, 8);

        // error messages
        if (temp_state.invalid_image_selected) {
            igSpacing();
            igTextWrapped("Error: image width not compatible with tile size/spacing");
            igSpacing();
        }

        if (temp_state.error_loading_file) {
            igSpacing();
            igTextWrapped("Error: could not load file");
            igSpacing();
        }

        igSeparator();

        var size = ogGetContentRegionAvail();
        if (igButton("Cancel", ImVec2{ .x = (size.x - 4) / 2 })) {
            igCloseCurrentPopup();
        }
        igSameLine(0, 4);

        if (!temp_state.has_image) {
            igPushItemFlag(ImGuiItemFlags_Disabled, true);
            igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
        }

        if (igButton("Load", ImVec2{ .x = -1, .y = 0 })) {
            // load the image and validate that its width is divisible by the tile size (take spacing into account too)
            if (validateImage()) {
                state.map.image = upaya.mem.allocator.dupe(u8, temp_state.image[0..std.mem.lenZ(temp_state.image)]) catch unreachable;
                state.map.tile_size = temp_state.tile_size;
                state.map.tile_spacing = temp_state.tile_spacing;
                state.tiles_per_row = 0;
                state.map_rect_size = @intToFloat(f32, state.map.tile_size * state.prefs.tile_size_multiplier);

                state.texture.deinit();
                state.texture = upaya.Texture.initFromFile(state.map.image, .nearest) catch unreachable;
                ogImage(state.texture.imTextureID(), state.texture.width, state.texture.height); // hack to fix a render bug on windows
                igCloseCurrentPopup();
            }
        }

        if (!temp_state.has_image) {
            igPopItemFlag();
            igPopStyleVar(1);
        }
    }
}

fn validateImage() bool {
    const image_contents = upaya.fs.read(upaya.mem.tmp_allocator, std.mem.spanZ(&temp_state.image)) catch unreachable;
    var w: c_int = 0;
    var h: c_int = 0;
    var comp: c_int = 0;
    if (stb.stbi_info_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &comp) == 1) {
        const max_tiles = @intCast(usize, w) / temp_state.tile_size;
        var i: usize = 3;
        while (i <= max_tiles) : (i += 1) {
            const space = (2 * temp_state.tile_spacing) + (i - 1) * temp_state.tile_spacing;
            const filled = i * temp_state.tile_size;
            if (space + filled == w) {
                return true;
            }
        }

        temp_state.invalid_image_selected = true;
        return false;
    }

    temp_state.error_loading_file = true;
    return false;
}

fn resizeMapPopup(state: *ts.AppState) void {
    if (igBeginPopupModal("Resize Map", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        _ = ogDrag(usize, "Width", &temp_state.map_width, 0.5, 16, 512);
        _ = ogDrag(usize, "Height", &temp_state.map_height, 0.5, 16, 512);
        igSeparator();

        if (temp_state.map_width < state.map.w or temp_state.map_height < state.map.h) {
            igSpacing();
            igPushStyleColorU32(ImGuiCol_Text, ts.colors.colorRgb(200, 200, 30));
            igTextWrapped("Warning: resizing to a smaller size will result in map data loss and objects outside of the map boundary will be moved.");
            igPopStyleColor(1);
            igSpacing();
        }

        igSpacing();
        igTextWrapped("Note: when resizing a map all undo/redo data will be purged");
        igSpacing();

        var size = ogGetContentRegionAvail();
        if (igButton("Cancel", ImVec2{ .x = (size.x - 4) / 2 })) {
            igCloseCurrentPopup();
        }
        igSameLine(0, 4);
        if (igButton("Apply", ImVec2{ .x = -1, .y = 0 })) {
            state.resizeMap(temp_state.map_width, temp_state.map_height);
            igCloseCurrentPopup();
        }
    }
}

var help_section: enum { overview, input_map, rules, rulesets, tags_objects, tile_definitions, shortcuts } = .overview;

fn helpPopup() void {
    igSetNextWindowSize(.{ .x = 500, .y = -1 }, ImGuiCond_Always);
    if (igBeginPopupModal("Help", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        igColumns(2, "id", true);
        igSetColumnWidth(0, 110);

        igPushItemWidth(-1);
        if (igListBoxHeaderVec2("", .{})) {
            defer igListBoxFooter();

            if (igSelectableBool("Overview", help_section == .overview, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .overview;
            }
            if (igSelectableBool("Input Map", help_section == .input_map, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .input_map;
            }
            if (igSelectableBool("Rules", help_section == .rules, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .rules;
            }
            if (igSelectableBool("RuleSets", help_section == .rulesets, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .rulesets;
            }
            if (igSelectableBool("Tags/Objects", help_section == .tags_objects, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .tags_objects;
            }
            if (igSelectableBool("Tile Defs", help_section == .tile_definitions, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .tile_definitions;
            }
            if (igSelectableBool("Shortcuts", help_section == .shortcuts, ImGuiSelectableFlags_DontClosePopups, .{})) {
                help_section = .shortcuts;
            }
        }
        igPopItemWidth();

        igNextColumn();
        switch (help_section) {
            .overview => helpOverview(),
            .input_map => helpInputMap(),
            .rules => helpRules(),
            .rulesets => helpRuleSets(),
            .tags_objects => helpTagsObjects(),
            .tile_definitions => helpTileDefinitions(),
            .shortcuts => helpShortCuts(),
        }

        igColumns(1, "id", false);
        if (ogButton("Close")) {
            igCloseCurrentPopup();
        }
    }
}

fn helpOverview() void {
    igTextWrapped("TileScript lets you setup Rules that are used to generate a tilemap. This allows you to paint a simple map with premade brushes which is then transformed into something more complex. This is done by using the Rules to dictate how they will map to your actual tileset. Additional RuleSets can be added that contain Rules that run only on the basic brushes before being transformed to your tileset.");
}

fn helpInputMap() void {
    igTextWrapped("The input map consists of the raw tile data that is passed through your Rules to generate the final tilemap. Left-click and drag to paint with the current brush. Right-click and drag to erase.");
}

fn helpRules() void {
    igTextWrapped("Rules are required for data to be transformed from the input map to the output map. Every Rule is run for each tile in the input map. A Rule consists of a pattern and one or more result tiles. If the Rule pattern passes, one of the result tiles will be passed along to the output map. A Rule can be made to randomly fail by setting the Chance value to less than 100%.");
}

fn helpRuleSets() void {
    igTextWrapped("Additional RuleSets can be added that operate only on the raw map data. The Rules in a RuleSet are run on the input map and create an intermediate map (visible by opening the Post Processed Map window) that is then processed with the main Ruels to generate the tilemap. RuleSets can be set to repeat one or more times allowing you to do flood fills, grow plants and use many other recursive techniques.");
}

fn helpTagsObjects() void {
    igTextWrapped("Tags let you associate a string with one or more tiles. This data is exported for you to use however you want.");
    igSeparator();
    igTextWrapped("Objects can be created and placed on any tile in the Output Map. You can define custom data (float/int/string/link) for each object. When in object edit mode, you can drag objects to place them. You can link two objects by Cmd/Alt dragging from one to another.");
}

fn helpTileDefinitions() void {
    igTextWrapped("Tile Definitions provide a way to select one or more tiles from your tileset per type. This data is exported and can be used to handle collision detection.");
}

fn helpShortCuts() void {
    igTextUnformatted("1 - 9: quick brush selector\nShift + drag tab: enable window docking\nCmd/Ctrl + z: undo\nShift + Cmd/Ctrl + z: redo\nTab: toggle tile/object mode\nArrow up/down: zoom in/out", null);
    igSeparator();
    igTextUnformatted("Input Map Shortcuts\nAlt/Cmd + left mouse drag: reposition map\nAlt + mouse wheel: zoom in/out\nShift + left mouse drag: paint rectangle\nShift + right mouse drag: clear rectangle", null);
}
