const std = @import("std");
const upaya = @import("upaya.zig");

/// reads the contents of a file. Returned value is owned by the caller and must be freed!
pub fn read(allocator: *std.mem.Allocator, filename: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try upaya.mem.allocator.alloc(u8, file_size);
    const bytes_read = try file.read(buffer[0..buffer.len]);

    return buffer;
}

pub fn write(filename: []const u8, data: []u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{.write = true});
    defer file.close();

    const file_size = try file.getEndPos();
    try file.writeAll(data);
}

/// gets a path to `filename` in the save games directory
pub fn getSaveGamesFile(app: []const u8, filename: []const u8) ![]u8 {
    const dir = try std.fs.getAppDataDir(upaya.mem.tmp_allocator, app);
    try std.fs.cwd().makePath(dir);
    return try std.fs.path.join(upaya.mem.tmp_allocator, &[_][]const u8{ dir, filename });
}

/// saves a serializable struct to disk
pub fn savePrefs(app: []const u8, filename: []const u8, data: anytype) !void {
    const file = try getSaveGamesFile(app, filename);
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();

    var serializer = std.io.serializer(.Little, .Byte, handle.writer());
    try serializer.serialize(data);
}

pub fn readPrefs(comptime T: type, app: []const u8, filename: []const u8) !T {
    const file = try getSaveGamesFile(app, filename);
    var handle = try std.fs.cwd().openFile(file, .{});
    defer handle.close();

    var deserializer = std.io.deserializer(.Little, .Byte, handle.reader());
    return deserializer.deserialize(T);
}

pub fn savePrefsJson(app: []const u8, filename: []const u8, data: anytype) !void {
    const file = try getSaveGamesFile(app, filename);
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();

    try std.json.stringify(data, .{ .whitespace = .{} }, handle.writer());
}

pub fn readPrefsJson(comptime T: type, app: []const u8, filename: []const u8) !T {
    const file = try getSaveGamesFile(app, filename);
    var bytes = try upaya.fs.read(upaya.mem.tmp_allocator, file);
    var tokens = std.json.TokenStream.init(bytes);

    const options = std.json.ParseOptions{ .allocator = upaya.mem.allocator };
    return try std.json.parse(T, &tokens, options);
}

/// for prefs loaded with `readPrefsJson` that have allocated fields, this must be called to free them
pub fn freePrefsJson(data: anytype) void {
    const options = std.json.ParseOptions{ .allocator = upaya.mem.allocator };
    std.json.parseFree(@TypeOf(data), data, options);
}

test "test fs read" {
    upaya.mem.initTmpAllocator();
    std.testing.expectError(error.FileNotFound, read(std.testing.allocator, "junk.png"));
    // var bytes = try read(std.testing.allocator, "src/assets/fa-solid-900.ttf");
    // std.testing.allocator.free(bytes);
}
