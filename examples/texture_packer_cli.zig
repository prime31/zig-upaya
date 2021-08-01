const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const fs = std.fs;

pub fn main() !void {
    upaya.mem.initTmpAllocator();

    var parser = upaya.ArgParser.init();
    try parser.parseArgs();

    if (parser.has("-h")) {
        std.debug.warn("Usage is the following: packer -o output/folder -n output_file_name path/to/image/folder\n", .{});
        return;
    }

    if (!parser.has("-o")) {
        std.debug.print("Missing output folder parameter: -o\n", .{});
        return;
    }

    if (!parser.has("-n")) {
        std.debug.print("Missing output file name parameter: -n\n", .{});
        return;
    }

    if (parser.values.items.len == 0) {
        std.debug.print("Missing input folder\n", .{});
        return;
    }

    const out_folder = parser.get("-o");
    const out_name = parser.get("-n");
    const in_folder = parser.values.items[0];

    if (fs.cwd().openDir(in_folder, .{})) {
        const atlas = upaya.TexturePacker.pack(in_folder) catch unreachable;
        defer atlas.deinit();

        atlas.save(out_folder, out_name);
        std.debug.print("texture atlas generated successfully\n", .{});
    } else |err| {
        std.debug.print("Invalid input directory: {s}, err: {}\n", .{ in_folder, err });
    }
}
