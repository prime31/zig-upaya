// include all files with tests
comptime {
    _ = @import("fs.zig");
    _ = @import("mem/mem.zig");
    _ = @import("mem/scratch_allocator.zig");
}
