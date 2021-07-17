const std = @import("std");
const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: *std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = &gpa.allocator;

pub fn initTmpAllocator() void {
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = &tmp_allocator_instance.allocator;
}
