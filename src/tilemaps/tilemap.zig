const std = @import("std");

pub const Tilemap = struct {
    w: usize,
    h: usize,
    map: []u8,

    pub fn initWithData(data: []const u8, width: usize, height: usize) Tilemap {
        return .{
            .w = width,
            .h = height,
            .map = std.mem.dupe(std.testing.allocator, u8, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        std.testing.allocator.free(self.map);
    }

    pub fn rotate(self: *Tilemap) void {
        var rotated = std.testing.allocator.alloc(u8, self.map.len) catch unreachable;

        var y: usize = 0;
        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                rotated[y + x * self.h] = self.map[x + y * self.w];
            }
        }

        std.testing.allocator.free(self.map);
        self.map = rotated;
        std.mem.swap(usize, &self.w, &self.h);
    }

    pub fn print(self: Tilemap) void {
        var y: usize = 0;
        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                std.debug.print("{}, ", .{self.map[x + y * self.w]});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};