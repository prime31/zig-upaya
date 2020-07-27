
// include all files with tests
comptime {
    _ = @import("fs.zig");
    _ = @import("mem/sdl_allocator.zig");
    _ = @import("mem/scratch_allocator.zig");
    _ = @import("mem/sdl_stream.zig");

}
