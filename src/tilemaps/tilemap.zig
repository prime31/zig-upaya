const std = @import("std");
const upaya = @import("../upaya.zig");

pub const Tilemap = struct {
    w: usize,
    h: usize,
    data: []u8,

    pub fn init(width: usize, height: usize) Tilemap {
        var map = Tilemap{
            .w = width,
            .h = height,
            .data = upaya.mem.allocator.alloc(u8, width * height) catch unreachable,
        };
        map.reset();
        return map;
    }

    pub fn initWithData(data: []const u8, width: usize, height: usize) Tilemap {
        return .{
            .w = width,
            .h = height,
            .data = std.mem.dupe(upaya.mem.allocator, u8, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        upaya.mem.allocator.free(self.data);
    }

    pub fn reset(self: Tilemap) void {
        std.mem.set(u8, self.data, 0);
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
        return self.data[x + y * self.w];
    }

    pub fn setTile(self: Tilemap, x: usize, y: usize, value: u8) void {
        self.data[x + y * self.w] = value;
    }
};
