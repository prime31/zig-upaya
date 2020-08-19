const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const fs = std.fs;
const clap = upaya.clap;

pub fn main() !void {
    upaya.mem.initTmpAllocator();

    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h, --help") catch unreachable,
        clap.parseParam("-o, --out <N>") catch unreachable,
        clap.parseParam("-n, --name <N>") catch unreachable,
        clap.Param(clap.Help){
            .takes_value = true,
        },
    };

    var args = try upaya.clap.parse(clap.Help, &params, upaya.mem.allocator);
    defer args.deinit();

    if (args.flag("--help")) {
        std.debug.warn("Usage is the following: tp -o output/folder path/to/image/folder\n", .{});
        return;
    }

    const out_folder = if (args.option("--out")) |out_folder| out_folder else null;
    if (out_folder == null) {
        std.debug.print("Missing output folder parameter: -o\n", .{});
        return;
    }

    const out_name = if (args.option("--name")) |out_name| out_name else null;
    if (out_name == null) {
        std.debug.print("Missing output name: -n\n", .{});
        return;
    }

    if (args.positionals().len == 0) {
        std.debug.print("Missing input folder\n", .{});
        return;
    }

    const in_folder = args.positionals()[0];

    if (fs.cwd().openDir(in_folder, .{})) |dir| {
        const atlas = upaya.TexturePacker.pack(in_folder) catch unreachable;
        defer atlas.deinit();

        atlas.save(out_folder.?, out_name.?);
        std.debug.print("texture atlas generated successfully\n", .{});
    } else |err| {
        std.debug.print("Invalid input directory: {}, err: {}\n", .{ in_folder, err });
    }
}
