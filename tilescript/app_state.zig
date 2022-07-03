const std = @import("std");
const upaya = @import("upaya");
const imgui = @import("imgui");

const persistence = @import("persistence.zig");
const ts = @import("tilescript.zig");

const TileScript = ts.TileScript;
const Texture = upaya.Texture;
const Map = ts.Map;

pub const AppState = struct {
    map: Map,
    // general state
    opened_file: ?[]const u8 = null,
    exported_file: ?[]const u8 = null,
    object_edit_mode: bool = false,
    selected_brush_index: usize = 0,
    texture: Texture,
    tiles_per_row: usize = 0,
    map_rect_size: f32 = 12,
    // toasts
    toast_timer: i32 = -1,
    toast_text: [255]u8 = undefined,
    // map data
    map_data_dirty: bool = true,
    processed_map_data: []u8,
    final_map_data: []u8,
    random_map_data: []Randoms,
    prefs: Prefs = .{
        .windows = .{},
    },

    pub const Randoms = struct {
        float: f32,
        int: usize,
    };

    /// persisted data
    pub const Prefs = struct {
        // ui state
        show_animations: bool = false,
        show_objects: bool = true,
        tile_size_multiplier: usize = 1,
        win_x: i32 = 0,
        win_y: i32 = 0,
        win_w: i32 = 1024,
        win_h: i32 = 768,
        // menu state
        windows: struct {
            objects: bool = false,
            object_editor: bool = false,
            tags: bool = false,
            tile_definitions: bool = false,
            animations: bool = false,
            post_processed_map: bool = true,
        },
    };

    /// generates a texture with 4x4, 16px blocks of color
    pub fn generateTexture() Texture {
        const rc = upaya.math.rand.color;
        var colors = [_]u32{
            ts.colors.brushes[12], ts.colors.brushes[11], ts.colors.brushes[10], ts.colors.brushes[9],
            ts.colors.brushes[8],  ts.colors.brushes[7],  ts.colors.brushes[6],  ts.colors.brushes[5],
            ts.colors.brushes[4],  ts.colors.brushes[3],  ts.colors.brushes[2],  ts.colors.brushes[1],
            rc().value,            rc().value,            rc().value,            rc().value,
        };

        var pixels: [16 * 4 * 16 * 4]u32 = undefined;
        var y: usize = 0;
        while (y < 16 * 4) : (y += 1) {
            var x: usize = 0;
            while (x < 16 * 4) : (x += 1) {
                const xx = @divTrunc(x, 16);
                const yy = @divTrunc(y, 16);
                pixels[x + y * 16 * 4] = colors[xx + yy * 2];
            }
        }

        return Texture.initWithColorData(&pixels, 16 * 4, 16 * 4, .nearest);
    }

    pub fn init() AppState {
        @setEvalBranchQuota(10000);
        const prefs = upaya.fs.readPrefsJson(AppState.Prefs, "aya_tile", "prefs.json") catch AppState.Prefs{ .windows = .{} };
        // aya.window.setSize(prefs.win_w, prefs.win_h);
        if (prefs.win_x != 0 and prefs.win_y != 0) {
            // aya.window.setPosition(prefs.win_x, prefs.win_y);
        }

        // load up a temp map
        const tile_size = 16;
        const map = Map.init(tile_size, 0);

        var state = AppState{
            .map = map,
            .map_rect_size = @intToFloat(f32, tile_size * prefs.tile_size_multiplier),
            .processed_map_data = upaya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .final_map_data = upaya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .random_map_data = upaya.mem.allocator.alloc(Randoms, 64 * 64) catch unreachable,
            .texture = generateTexture(),
            .prefs = prefs,
        };
        state.generateRandomData(state.map.ruleset.seed);

        // test data for messing with folders
        // var i: usize = 10;
        // while (i < 20) : (i += 1) {
        //     state.map.ruleset.addRule();
        //     var rule = &state.map.ruleset.rules.items[state.map.ruleset.rules.items.len - 1];
        //     std.mem.copy(u8, &rule.name, std.fmt.allocPrint(upaya.mem.tmp_allocator, "Rule {}", .{i}) catch unreachable);
        // }

        return state;
    }

    pub fn savePrefs(self: *AppState) void {
        // aya.window.size(&self.prefs.win_w, &self.prefs.win_h);
        // aya.window.position(&self.prefs.win_x, &self.prefs.win_y);
        upaya.fs.savePrefsJson("aya_tile", "prefs.json", self.prefs) catch unreachable;
    }

    /// returns the number of tiles in each row of the tileset image
    pub fn tilesPerRow(self: *AppState) usize {
        // calculate tiles_per_row if needed
        if (self.tiles_per_row == 0) {
            var accum: usize = self.map.tile_spacing * 2;
            while (true) {
                self.tiles_per_row += 1;
                accum += self.map.tile_size + self.map.tile_spacing;
                if (accum >= self.texture.width) {
                    break;
                }
            }
        }
        return self.tiles_per_row;
    }

    pub fn tilesPerCol(self: *AppState) usize {
        var tiles_per_col: usize = 0;
        var accum: usize = self.map.tile_spacing * 2;
        while (true) {
            tiles_per_col += 1;
            accum += self.map.tile_size + 2 * self.map.tile_spacing;
            if (accum >= self.texture.height) {
                break;
            }
        }
        return tiles_per_col;
    }

    pub fn mapSize(self: AppState) imgui.ImVec2 {
        return imgui.ImVec2{ .x = @intToFloat(f32, self.map.w) * self.map_rect_size, .y = @intToFloat(f32, self.map.h) * self.map_rect_size };
    }

    /// resizes the map and all of the sub-maps
    pub fn resizeMap(self: *AppState, w: usize, h: usize) void {
        ts.history.reset();
        self.map_data_dirty = true;
        const shrunk = self.map.w > w or self.map.h > h;

        // map_data is our source so we need to copy the old data into a temporary slice
        var new_slice = upaya.mem.allocator.alloc(u8, w * h) catch unreachable;
        std.mem.set(u8, new_slice, 0);

        // copy taking into account that we may have shrunk
        const max_x = std.math.min(self.map.w, w);
        const max_y = std.math.min(self.map.h, h);
        var y: usize = 0;
        while (y < max_y) : (y += 1) {
            var x: usize = 0;
            while (x < max_x) : (x += 1) {
                new_slice[x + y * w] = self.map.getTile(x, y);
            }
        }

        self.map.w = w;
        self.map.h = h;

        upaya.mem.allocator.free(self.map.data);
        self.map.data = new_slice;

        // resize our two generated maps
        upaya.mem.allocator.free(self.processed_map_data);
        upaya.mem.allocator.free(self.final_map_data);
        upaya.mem.allocator.free(self.random_map_data);
        self.processed_map_data = upaya.mem.allocator.alloc(u8, w * h) catch unreachable;
        self.final_map_data = upaya.mem.allocator.alloc(u8, w * h) catch unreachable;
        self.random_map_data = upaya.mem.allocator.alloc(Randoms, w * h) catch unreachable;

        // if we shrunk handle anything that needs to be fixed
        if (shrunk) {
            for (self.map.objects.items) |*anim| {
                if (anim.x >= w) anim.x = w - 1;
                if (anim.y >= h) anim.y = h - 1;
            }
        }
    }

    /// regenerates the stored random data per tile. Only needs to be called on seed change or map resize
    pub fn generateRandomData(self: *AppState, seed: u64) void {
        upaya.math.rand.seed(seed);

        // pre-generate random data per tile
        var i: usize = 0;
        while (i < self.map.w * self.map.h) : (i += 1) {
            self.random_map_data[i] = .{
                .float = upaya.math.rand.float(f32),
                .int = upaya.math.rand.int(usize),
            };
        }
    }

    pub fn getProcessedTile(self: AppState, x: usize, y: usize) u32 {
        if (x >= self.map.w or y >= self.map.h) {
            return 0;
        }
        return self.processed_map_data[x + y * @intCast(usize, self.map.w)];
    }

    pub fn showToast(self: *AppState, text: []const u8, duration: i32) void {
        std.mem.copy(u8, &self.toast_text, text);
        self.toast_timer = duration;
    }

    pub fn saveMap(self: AppState, file: []const u8) !void {
        try persistence.save(self.map, file);
    }

    pub fn exportJson(self: AppState, file: []const u8) !void {
        try persistence.exportJson(self.map, self.final_map_data, file);
    }

    pub fn clearQuickFile(self: *AppState, which: enum { opened, exported }) void {
        var file = if (which == .opened) &self.opened_file else &self.exported_file;
        if (file.* != null) {
            upaya.mem.allocator.free(file.*.?);
            file.* = null;
        }
    }

    pub fn toggleEditMode(self: *AppState) void {
        self.object_edit_mode = !self.object_edit_mode;
        ts.colors.toggleObjectMode(self.object_edit_mode);
        self.showToast(if (self.object_edit_mode) "Entering object edit mode" else "Exiting object edit mode", 70);
    }

    pub fn loadMap(self: *AppState, file: []const u8) !void {
        if (std.mem.endsWith(u8, file, ".ts")) {
            self.map = try persistence.load(file);
        } else if (std.mem.endsWith(u8, file, ".tkp")) {
            self.map = try @import("tilekit_importer.zig").import(file);
        }

        self.map_rect_size = @intToFloat(f32, self.map.tile_size * self.prefs.tile_size_multiplier);

        const curr_dir = try std.fs.cwd().openDir(std.fs.path.dirname(file).?, .{});
        try curr_dir.setAsCwd();

        // unload old texture and load new texture
        self.texture.deinit();

        if (std.mem.len(self.map.image) == 0) {
            self.texture = generateTexture();
            self.map.tile_size = 16;
        } else {
            try curr_dir.access(self.map.image, .{});
            const image_path = try std.fs.path.join(upaya.mem.tmp_allocator, &[_][]const u8{ std.fs.path.dirname(file).?, self.map.image });
            self.texture = try Texture.initFromFile(image_path, .nearest);
        }

        // resize and clear processed_map_data and final_map_data
        upaya.mem.allocator.free(self.processed_map_data);
        upaya.mem.allocator.free(self.final_map_data);
        upaya.mem.allocator.free(self.random_map_data);

        self.processed_map_data = try upaya.mem.allocator.alloc(u8, self.map.w * self.map.h);
        self.final_map_data = try upaya.mem.allocator.alloc(u8, self.map.w * self.map.h);
        self.random_map_data = upaya.mem.allocator.alloc(Randoms, self.map.w * self.map.h) catch unreachable;
        self.map_data_dirty = true;
        self.tiles_per_row = 0;

        // keep our file so we can save later and clear our exported file if we have one
        self.clearQuickFile(.opened);
        self.opened_file = try upaya.mem.allocator.dupe(u8, file);

        self.clearQuickFile(.exported);
    }
};
