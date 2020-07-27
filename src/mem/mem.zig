const std = @import("std");
const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

pub const BufferStream = @import("stream.zig").BufferStream;

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: *std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

// default to the SDL c allocator for now
pub const allocator = @import("allocator.zig").c_allocator;

pub fn initTmpAllocator() void {
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = &tmp_allocator_instance.allocator;
}
