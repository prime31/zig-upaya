const std = @import("std");
const upaya = @import("../upaya.zig");
const io = std.io;

pub const SdlBufferStream = struct {
    file: std.fs.File,

    pub const ReadError = std.fs.File.ReadError;
    pub const WriteError = std.fs.File.WriteError;
    pub const Reader = io.Reader(*SdlBufferStream, ReadError, read);
    pub const Writer = io.Writer(*SdlBufferStream, WriteError, write);

    pub fn init(file: []const u8, mode: enum{read, write}) SdlBufferStream {
        if (mode == .write) return .{ .file = std.fs.cwd().createFile(file, .{}) catch unreachable };
        return .{ .file = std.fs.cwd().openFile(file, .{}) catch unreachable };
    }

    pub fn deinit(self: SdlBufferStream) void {
        self.file.close();
    }

    pub fn reader(self: *SdlBufferStream) Reader {
        return .{ .context = self };
    }

    pub fn writer(self: *SdlBufferStream) Writer {
        return .{ .context = self };
    }

    pub fn read(self: *SdlBufferStream, dest: []u8) !usize {
        return try self.file.read(dest);
    }

    pub fn write(self: *SdlBufferStream, bytes: []const u8) !usize {
        return try self.file.write(bytes);
    }
};

test "SdlBufferStream output" {
    var buf = SdlBufferStream.init("/Users/desaro/Desktop/poop.txt", .write);
    const stream = buf.writer();

    try stream.print("{}{}!", .{ "Hello", "World" });
    buf.deinit();

    const written = try upaya.fs.read(std.testing.allocator, "/Users/desaro/Desktop/poop.txt");
    std.testing.expectEqualSlices(u8, "HelloWorld!", written);
    upaya.mem.allocator.free(written);
}
