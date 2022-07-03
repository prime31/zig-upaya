const std = @import("std");
const mem = @import("../mem/mem.zig");

/// super simple argument parser. Args must be in the form of "-arg value". Naked values that dont have a corresponding
/// "-key" preceding them are stuffed into the values ArrayList.
pub const ArgParser = struct {
    map: std.StringHashMap([]const u8),
    values: std.ArrayList([]const u8),

    pub fn init() ArgParser {
        return .{
            .map = std.StringHashMap([]const u8).init(mem.tmp_allocator),
            .values = std.ArrayList([]const u8).init(mem.tmp_allocator),
        };
    }

    pub fn parseArgs(self: *ArgParser) !void {
        var args = std.process.args();
        if (!args.skip()) return;

        var flag: ?[]const u8 = null;
        while (args.next()) |arg| {
            if (std.mem.startsWith(u8, arg, "-")) {
                flag = arg;
            } else if (flag) |flag_value| {
                try self.map.put(flag_value, arg);
                flag = null;
            } else {
                try self.values.append(arg);
            }
        }
    }

    pub fn has(self: ArgParser, key: []const u8) bool {
        return self.map.contains(key);
    }

    pub fn get(self: ArgParser, key: []const u8) []const u8 {
        return self.map.get(key).?;
    }
};
