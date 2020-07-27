const std = @import("std");

pub const c_allocator = &c_allocator_state;
var c_allocator_state = std.mem.Allocator{
    .allocFn = cAlloc,
    .resizeFn = cResize,
};

fn cAlloc(allocator: *std.mem.Allocator, len: usize, ptr_align: u29, len_align: u29) ![]u8 {
    std.debug.assert(ptr_align <= @alignOf(c_longdouble));
    const ptr = @ptrCast([*]u8, std.c.malloc(len) orelse return error.OutOfMemory);

    if (len_align == 0) {
        return ptr[0..len];
    }

    return ptr[0..std.mem.alignBackwardAnyAlign(len, len_align)];
}

fn cResize(self: *std.mem.Allocator, old_mem: []u8, new_len: usize, len_align: u29) std.mem.Allocator.Error!usize {
    if (new_len == 0) {
        std.c.free(old_mem.ptr);
        return 0;
    }

    if (new_len <= old_mem.len) {
        _ = std.c.realloc(old_mem.ptr, new_len) orelse return error.OutOfMemory;
        return std.mem.alignAllocLen(old_mem.len, new_len, len_align);
    }

    return error.OutOfMemory;
}
