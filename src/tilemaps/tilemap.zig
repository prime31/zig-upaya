const std = @import("std");
const upaya = @import("../upaya.zig");

pub const Tilemap = struct {
    w: usize,
    h: usize,
    layers: []Layer,
    current_layer: usize = 0,

    pub const Layer = struct {
        name: []const u8,
        data: []u8,

        pub fn init(name: []const u8, size: usize) Layer {
            var layer = Layer{
                .name = upaya.mem.allocator.dupeZ(u8, name) catch unreachable,
                .data = upaya.mem.allocator.alloc(u8, size) catch unreachable,
            };
            layer.clear();
            return layer;
        }

        pub fn deinit(self: Layer) void {
            for (self.layers) |layer| {
                upaya.mem.allocator.free(layer.data);
                upaya.mem.allocator.free(layer.name);
            }
        }

        pub fn clear(self: Layer) void {
            std.mem.set(u8, self.data, 0);
        }
    };

    pub fn init(width: usize, height: usize) Tilemap {
        var map = Tilemap{
            .w = width,
            .h = height,
            .layers = upaya.mem.allocator.alloc(Layer, 1) catch unreachable,
        };
        map.layers[0] = Layer.init("Layer 1", map.w * map.h);
        return map;
    }

    pub fn initWithData(data: []const u8, width: usize, height: usize) Tilemap {
        return .{
            .w = width,
            .h = height,
            .data = upaya.mem.allocator.dupe(u8, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        upaya.mem.allocator.free(self.data);
    }

    pub fn addLayer(self: *Tilemap) void {
        self.layers = upaya.mem.allocator.realloc(self.layers, self.layers.len + 1) catch unreachable;
        self.layers[self.layers.len - 1] = Layer.init("Layer", self.w * self.h);
    }

    pub fn rotate(self: *Tilemap) void {
        var rotated = upaya.mem.allocator.alloc(u8, self.data.len) catch unreachable;

        var y: usize = 0;
        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                rotated[y + x * self.h] = self.data[x + y * self.w];
            }
        }

        std.testing.allocator.free(self.data);
        self.data = rotated;
        std.mem.swap(usize, &self.w, &self.h);
    }

    pub fn print(self: Tilemap) void {
        var y: usize = 0;
        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                std.debug.print("{}, ", .{self.data[x + y * self.w]});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }

    pub fn getTile(self: Tilemap, x: usize, y: usize) u8 {
        if (x > self.w or y > self.h) {
            return 0;
        }
        return self.layers[self.current_layer].data[x + y * self.w];
    }

    pub fn setTile(self: Tilemap, x: usize, y: usize, value: u8) void {
        self.layers[self.current_layer].data[x + y * self.w] = value;
    }
};
