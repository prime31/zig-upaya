const upaya = @import("upaya.zig");

pub const mem = struct {
    pub var tmp_allocator: *std.mem.Allocator = upaya.mem.tmp_allocator;
    pub const allocator = upaya.mem.allocator;
};

pub const fs = upaya.fs;