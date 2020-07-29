const std = @import("std");
const print = std.debug.print;
usingnamespace @import("imgui");
const upaya = @import("upaya");
const Texture = upaya.Texture;

const rules_win = @import("windows/rules.zig");
const brushes_win = @import("windows/brushes.zig");
const tags_win = @import("windows/tags.zig");
const tile_definitions_win = @import("windows/tile_definitions.zig");
const objects_win = @import("windows/objects.zig");
const object_editor_win = @import("windows/object_editor.zig");
const animations_win = @import("windows/animations.zig");
const input_map_wins = @import("windows/maps.zig");
const output_map_win = @import("windows/output_map.zig");

const menu = @import("menu.zig");

pub const data = @import("map.zig");
pub const history = @import("history.zig");
pub const colors = @import("colors.zig");

pub const AppState = @import("app_state.zig").AppState;
pub const Map = data.Map;
pub const drawBrush = brushes_win.drawBrush;

const files = @import("filebrowser");

pub const TileScript = struct {
    state: AppState,

    pub fn init() TileScript {
        colors.init();
        history.init();
        return .{ .state = AppState.init() };
    }

    pub fn deinit(self: *TileScript) void {
        history.deinit();
        self.state.texture.deinit();
        self.state.map.deinit();
        upaya.mem.allocator.free(self.state.processed_map_data);
        upaya.mem.allocator.free(self.state.final_map_data);
        upaya.mem.allocator.free(self.state.random_map_data);
    }

    pub fn handleDroppedFile(self: *TileScript, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".ts") or std.mem.endsWith(u8, file, ".tkp")) {
            self.state.loadMap(file) catch unreachable;
        } else if (std.mem.endsWith(u8, file, ".png")) {
            menu.loadTileset(file);
        } else {
            self.state.showToast("Invalid file.", 100);
        }
    }

    pub fn draw(self: *TileScript) void {
        menu.draw(&self.state);

        rules_win.draw(&self.state);
        brushes_win.drawWindow(&self.state);
        input_map_wins.drawWindows(&self.state);
        output_map_win.drawWindow(&self.state);
        brushes_win.drawPopup(&self.state, "##brushes-root");
        tags_win.draw(&self.state);
        tile_definitions_win.draw(&self.state);
        objects_win.draw(&self.state);
        object_editor_win.draw(&self.state);
        animations_win.draw(&self.state);

        // toast notifications
        if (self.state.toast_timer > 0) {
            self.state.toast_timer -= 1;

            igPushStyleColorU32(ImGuiCol_WindowBg, colors.colorRgba(90, 90, 130, 255));
            igSetNextWindowPos(ogGetWindowCenter(), ImGuiCond_Always, .{ .x = 0.5, .y = 0.5 });
            if (igBegin("Toast Notification", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav)) {
                igText(&self.state.toast_text[0]);

                if (igIsItemHovered(ImGuiHoveredFlags_None) and igIsMouseClicked(ImGuiMouseButton_Left, false)) {
                    self.state.toast_timer = -1;
                }
            }
            igEnd();
            igPopStyleColor(1);
        }

        // igShowDemoWindow(null);
    }

    pub fn setupDockLayout(id: ImGuiID) void {
        var dock_main_id =  id;

        // dock_main_id is the left node after this
        const right_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Right, 0.37, null, &dock_main_id);
        igDockBuilderDockWindow("Rules", right_id);

        // dock_main_id is the bottom node after this
        const tl_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Up, 0.48, null, &dock_main_id);
        igDockBuilderDockWindow("Input Map", tl_id);

        igDockBuilderDockWindow("Post Processed Map", dock_main_id);
        igDockBuilderDockWindow("Output Map", dock_main_id);

        igDockBuilderFinish(id);
    }
};

// TODO: move these to a common utility file along with methods to draw brushes popup and tileset popup with single/multiple selection

/// helper to find the tile under the mouse given a top-left position of the grid and a grid size
pub fn tileIndexUnderMouse(rect_size: usize, origin: ImVec2) struct { x: usize, y: usize } {
    var pos = igGetIO().MousePos;
    pos.x -= origin.x;
    pos.y -= origin.y;

    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, pos.y), rect_size) };
}

pub fn tileIndexUnderPos(position: ImVec2, rect_size: usize, origin: ImVec2) struct { x: usize, y: usize } {
    var pos = position;
    pos.x -= origin.x;
    pos.y -= origin.y;

    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, pos.y), rect_size) };
}

/// helper to draw an image button with an image from the tileset
pub fn tileImageButton(state: *AppState, size: f32, tile: usize) bool {
    const rect = uvsForTile(state, tile);
    const uv0 = ImVec2{ .x = rect.x, .y = rect.y };
    const uv1 = ImVec2{ .x = rect.x + rect.w, .y = rect.y + rect.h };

    const tint = colors.colorRgbaVec4(255, 255, 255, 255);
    return igImageButton(state.texture.imTextureID(), ImVec2{ .x = size, .y = size }, uv0, uv1, 2, ImVec4{ .w = 1 }, tint);
}

pub fn uvsForTile(state: *AppState, tile: usize) upaya.math.Rect {
    const x = @intToFloat(f32, @mod(tile, state.tilesPerRow()));
    const y = @intToFloat(f32, @divTrunc(tile, state.tilesPerRow()));

    const inv_w = 1.0 / @intToFloat(f32, state.texture.width);
    const inv_h = 1.0 / @intToFloat(f32, state.texture.height);

    return .{
        .x = (x * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) + @intToFloat(f32, state.map.tile_spacing)) * inv_w,
        .y = (y * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) + @intToFloat(f32, state.map.tile_spacing)) * inv_h,
        .w = @intToFloat(f32, state.map.tile_size) * inv_w,
        .h = @intToFloat(f32, state.map.tile_size) * inv_h,
    };
}

/// adds a tile selection indicator to the draw list with an outline rectangle and a fill rectangle. Works for both tilesets and palettes.
pub fn addTileToDrawList(tile_size: usize, content_start_pos: ImVec2, tile: u8, per_row: usize, tile_spacing: usize) void {
    const x = @mod(tile, per_row);
    const y = @divTrunc(tile, per_row);

    var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, tile_size + tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, tile_size + tile_spacing) };
    tl.x += content_start_pos.x + @intToFloat(f32, tile_spacing);
    tl.y += content_start_pos.y + @intToFloat(f32, tile_spacing);
    ogAddQuadFilled(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size), colors.rule_result_selected_fill);

    // offset by 1 extra pixel because quad outlines are drawn larger than the size passed in and we shrink the size by our outline width
    tl.x += 1;
    tl.y += 1;
    ogAddQuad(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size - 2), colors.rule_result_selected_outline, 2);
}
