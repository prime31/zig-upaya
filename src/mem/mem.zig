const std = @import("std");

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: std.mem.Allocator = undefined;
var tmp_allocator_instance: std.heap.FixedBufferAllocator = undefined;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

pub fn initTmpAllocator() !void {
    tmp_allocator_instance = std.heap.FixedBufferAllocator.init(try allocator.alloc(u8, 2 * 1024 * 1024));
    tmp_allocator = tmp_allocator_instance.allocator();
}
