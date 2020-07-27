const std = @import("std");
const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

pub const SdlBufferStream = @import("sdl_stream.zig").SdlBufferStream;

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: *std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

// default to the SDL c allocator for now
pub const allocator = @import("sdl_allocator.zig").sdl_allocator;

pub fn initTmpAllocator() void {
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = &tmp_allocator_instance.allocator;
}
