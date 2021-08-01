const std = @import("std");
const fs = std.fs;
const Image = @import("../image.zig").Image;
const upaya = @import("../upaya_cli.zig");
const math = upaya.math;
const stb = @import("stb");

pub const TexturePacker = struct {
    pub const Atlas = struct {
        names: [][]const u8,
        rects: []math.RectI,
        w: u16,
        h: u16,
        image: upaya.Image = undefined,

        pub fn init(frames: []stb.stbrp_rect, files: [][]const u8, size: Size) Atlas {
            std.debug.assert(frames.len == files.len);
            var res_atlas = Atlas{
                .names = upaya.mem.allocator.alloc([]const u8, files.len) catch unreachable,
                .rects = upaya.mem.allocator.alloc(math.RectI, frames.len) catch unreachable,
                .w = size.width,
                .h = size.height,
            };

            // convert to upaya rects
            for (frames) |frame, i| {
                res_atlas.rects[i] = .{ .x = frame.x, .y = frame.y, .w = frame.w, .h = frame.h };
            }

            for (files) |file, i| {
                res_atlas.names[i] = std.mem.dupe(upaya.mem.allocator, u8, fs.path.basename(file)) catch unreachable;
            }

            // generate the atlas
            var image = upaya.Image.init(size.width, size.height);
            image.fillRect(.{ .w = size.width, .h = size.height }, upaya.math.Color.transparent);

            for (files) |file, i| {
                var sub_image = upaya.Image.initFromFile(file);
                defer sub_image.deinit();
                image.blit(sub_image, frames[i].x, frames[i].y);
            }

            res_atlas.image = image;
            return res_atlas;
        }

        pub fn deinit(self: Atlas) void {
            for (self.names) |name| {
                upaya.mem.allocator.free(name);
            }
            upaya.mem.allocator.free(self.names);
            upaya.mem.allocator.free(self.rects);
            self.image.deinit();
        }

        /// saves the atlas image and a json file with the atlas details. filename should be only the name with no extension.
        pub fn save(self: Atlas, folder: []const u8, filename: []const u8) void {
            const img_filename = std.mem.concat(upaya.mem.allocator, u8, &[_][]const u8{ filename, ".png" }) catch unreachable;
            const atlas_filename = std.mem.concat(upaya.mem.allocator, u8, &[_][]const u8{ filename, ".json" }) catch unreachable;

            var out_file = fs.path.join(upaya.mem.tmp_allocator, &[_][]const u8{ folder, img_filename }) catch unreachable;
            self.image.save(out_file);

            out_file = fs.path.join(upaya.mem.tmp_allocator, &[_][]const u8{ folder, atlas_filename }) catch unreachable;
            var handle = std.fs.cwd().createFile(out_file, .{}) catch unreachable;
            defer handle.close();

            const out_stream = handle.writer();
            const options = std.json.StringifyOptions{ .whitespace = .{} };

            std.json.stringify(.{ .names = self.names, .rects = self.rects }, options, out_stream) catch unreachable;
        }
    };

    pub const Size = struct {
        width: u16,
        height: u16,
    };

    pub fn pack(folder: []const u8) !Atlas {
        const pngs = upaya.fs.getAllFilesOfType(upaya.mem.allocator, folder, ".png", true);
        const frames = getFramesForPngs(pngs);
        if (runRectPacker(frames)) |atlas_size| {
            return Atlas.init(frames, pngs, atlas_size);
        } else {
            return error.NotEnoughRoom;
        }
    }

    fn getFramesForPngs(pngs: [][]const u8) []stb.stbrp_rect {
        var frames = std.ArrayList(stb.stbrp_rect).init(upaya.mem.allocator);
        for (pngs) |png, i| {
            var w: c_int = undefined;
            var h: c_int = undefined;
            _ = upaya.Image.getTextureSize(png, &w, &h);
            frames.append(.{
                .id = @intCast(c_int, i),
                .w = @intCast(u16, w),
                .h = @intCast(u16, h),
            }) catch unreachable;
        }

        return frames.toOwnedSlice();
    }

    fn runRectPacker(frames: []stb.stbrp_rect) ?Size {
        var ctx: stb.stbrp_context = undefined;
        const node_count = 4096 * 2;
        var nodes: [node_count]stb.stbrp_node = undefined;

        const texture_sizes = [_][2]c_int{
            [_]c_int{ 256, 256 },   [_]c_int{ 512, 256 },   [_]c_int{ 256, 512 },
            [_]c_int{ 512, 512 },   [_]c_int{ 1024, 512 },  [_]c_int{ 512, 1024 },
            [_]c_int{ 1024, 1024 }, [_]c_int{ 2048, 1024 }, [_]c_int{ 1024, 2048 },
            [_]c_int{ 2048, 2048 }, [_]c_int{ 4096, 2048 }, [_]c_int{ 2048, 4096 },
            [_]c_int{ 4096, 4096 }, [_]c_int{ 8192, 4096 }, [_]c_int{ 4096, 8192 },
        };

        for (texture_sizes) |tex_size| {
            stb.stbrp_init_target(&ctx, tex_size[0], tex_size[1], &nodes, node_count);
            stb.stbrp_setup_heuristic(&ctx, stb.STBRP_HEURISTIC_Skyline_default);
            if (stb.stbrp_pack_rects(&ctx, frames.ptr, @intCast(c_int, frames.len)) == 1) {
                return Size{ .width = @intCast(u16, tex_size[0]), .height = @intCast(u16, tex_size[1]) };
            }
        }

        return null;
    }
};
