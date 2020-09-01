const std = @import("std");
const upaya = @import("../upaya.zig");

pub const Tileset = struct {
    tile_size: usize,

    pub fn init(tile_size: usize) Tileset {
        return .{
            .tile_size = tile_size,
        };
    }
};