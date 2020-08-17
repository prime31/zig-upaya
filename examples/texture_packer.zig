const std = @import("std");
const upaya = @import("upaya");
const math = upaya.math;
const colors = upaya.colors;
const fs = std.fs;
usingnamespace upaya.imgui;
const stb = @import("stb");

var atlas: ?TexturePacker.Atlas = null;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .shutdown = shutdown,
        .docking = false,
        .width = 1024,
        .height = 768,
        .window_title = "Texture Packer",
        .onFileDropped = onFileDropped,
    });
}

fn init() void {}

fn shutdown() void {
    if (atlas) |a| a.deinit();
}

fn update() void {
    igSetNextWindowPos(.{}, ImGuiCond_Always, .{});
    igSetNextWindowSize(.{
        .x = @intToFloat(f32, upaya.sokol.sapp_width()),
        .y = @intToFloat(f32, upaya.sokol.sapp_height()),
    }, ImGuiCond_Always);

    if (igBegin("Main Window", null, ImGuiWindowFlags_NoTitleBar)) {
        if (atlas) |a| {
            igText("Atlas Size:");
            igSameLine(0, 5);

            igSetNextItemWidth(100);
            var tmp_size = [_]c_int{@intCast(c_int, a.w), @intCast(c_int, a.h)};
            _ = igInputInt2("", &tmp_size, ImGuiInputTextFlags_None);

            if (igBeginChildEx("#child", 666, ogGetContentRegionAvail(), true, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_HorizontalScrollbar)) {
                var pos = ogGetCursorScreenPos();
                const size = ImVec2{ .x = @intToFloat(f32, a.w), .y = @intToFloat(f32, a.h) };

                ogAddRectFilled(igGetWindowDrawList(), pos, size, colors.rgbToU32(0, 0, 0));
                ogAddRect(igGetWindowDrawList(), pos, size, colors.rgbToU32(155, 0, 155), 1);
                _ = igInvisibleButton("##rects", size);

                for (a.rects) |rect| {
                    const tl = .{ .x = pos.x + @intToFloat(f32, rect.x), .y = pos.y + @intToFloat(f32, rect.y) };
                    ogAddRect(igGetWindowDrawList(), tl, .{ .x = @intToFloat(f32, rect.w), .y = @intToFloat(f32, rect.h) }, colors.rgbToU32(0, 255, 0), 1);
                    drawChunk(tl, rect.asRect());
                }
                igEndChild();
            }
        }
    }
    igEnd();
}

fn drawChunk(tl: ImVec2, rect: math.Rect) void {
    var br = tl;
    br.x += rect.w;
    br.y += rect.h;

    const inv_w = 1.0 / @intToFloat(f32, atlas.?.w);
    const inv_h = 1.0 / @intToFloat(f32, atlas.?.h);

    const uv0 = ImVec2{ .x = rect.x * inv_w, .y = rect.y * inv_h };
    const uv1 = ImVec2{ .x = (rect.x + rect.w) * inv_w, .y = (rect.y + rect.h) * inv_h };

    ImDrawList_AddImage(igGetWindowDrawList(), atlas.?.texture.imTextureID(), tl, br, uv0, uv1, 0xffffffff);
}

fn solve() void {
    var ctx: stb.stbrp_context = undefined;
    const rects_size = @sizeOf(stb.stbrp_rect) * rects.len;
    const node_count = 4096 * 2;
    var nodes: [node_count]stb.stbrp_node = undefined;

    stb.stbrp_init_target(&ctx, texx_size, texx_size, &nodes, node_count);
    stb.stbrp_setup_heuristic(&ctx, @intCast(c_int, heuristic));
    last_pack_result = stb.stbrp_pack_rects(&ctx, rects.ptr, @intCast(c_int, rects.len)) == 1;
}

fn regenerateRects() void {
    var i: c_int = 0;
    while (i < rects.len) : (i += 1) {
        rects[@intCast(usize, i)] = .{
            .id = i,
            .x = 0,
            .y = 0,
            .w = upaya.math.rand.range(c_ushort, 50, 300),
            .h = upaya.math.rand.range(c_ushort, 50, 300),
        };
    }
}

fn onFileDropped(file: []const u8) void {
    if (fs.cwd().openDir(file, .{ .iterate = true })) |dir| {
        atlas = TexturePacker.pack(file);
    } else |err| {
        std.debug.print("Dropped a non-directory: {}, err: {}\n", .{ file, err });
    }
}

/// returns a slice of all the files with extension. The caller owns the slice AND each path in the slice.
pub fn getAllFilesOfType(allocator: *std.mem.Allocator, dir: fs.Dir, extension: []const u8, recurse: bool) [][]const u8 {
    var list = std.ArrayList([]const u8).init(allocator);

    var recursor = struct {
        fn search(alloc: *std.mem.Allocator, directory: fs.Dir, recursive: bool, filelist: *std.ArrayList([]const u8), ext: []const u8) void {
            directory.setAsCwd() catch unreachable;
            var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
            const dir_string = std.os.getcwd(&buffer) catch unreachable;

            var iter = directory.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .File) {
                    if (std.mem.endsWith(u8, entry.name, ext)) {
                        const abs_path = fs.path.join(alloc, &[_][]const u8{ dir_string, entry.name }) catch unreachable;
                        filelist.append(abs_path) catch unreachable;
                    }
                } else if (entry.kind == .Directory) {
                    const abs_path = fs.path.join(alloc, &[_][]const u8{ dir_string, entry.name }) catch unreachable;
                    search(alloc, directory.openDir(entry.name, .{ .iterate = true }) catch unreachable, recursive, filelist, ext);
                }
            }
        }
    }.search;

    recursor(allocator, dir, recurse, &list, extension);

    return list.toOwnedSlice();
}

const TexturePacker = struct {
    pub const Atlas = struct {
        names: [][]const u8,
        rects: []math.RectI,
        w: u16,
        h: u16,
        texture: upaya.Texture = undefined,

        pub fn init(frames: []stb.stbrp_rect, files: [][]const u8, size: Size) Atlas {
            std.debug.assert(frames.len == files.len);
            var res_atlas = Atlas{
                .names = upaya.mem.allocator.alloc([]const u8, files.len) catch unreachable,
                .rects = upaya.mem.allocator.alloc(math.RectI, frames.len) catch unreachable,
                .w = size.width,
                .h = size.height,
            };

            for (frames) |frame, i| {
                res_atlas.rects[i] = .{ .x = frame.x, .y = frame.y, .w = frame.w, .h = frame.h };
            }

            for (files) |file, i| {
                res_atlas.names[i] = std.mem.dupe(upaya.mem.allocator, u8, fs.path.basename(file)) catch unreachable;
            }

            // generate the atlas
            var image = upaya.Image.init(size.width, size.height);
            defer image.deinit();

            image.fillRect(.{.w = size.width, .h = size.height}, upaya.math.Color.transparent);

            for (files) |file, i| {
                var sub_image = upaya.Image.initFromFile(file);
                defer sub_image.deinit();
                image.blit(sub_image, frames[i].x, frames[i].y);
            }

            res_atlas.texture = upaya.Texture.initWithColorData(image.pixels, @intCast(i32, image.w), @intCast(i32, image.h), .nearest);

            return res_atlas;
        }

        pub fn deinit(self: Atlas) void {
            for (self.names) |name| {
                upaya.mem.allocator.free(name);
            }
            upaya.mem.allocator.free(self.names);
            upaya.mem.allocator.free(self.rects);
        }
    };

    pub const Size = struct {
        width: u16,
        height: u16,
    };

    pub fn pack(folder: []const u8) ?Atlas {
        if (fs.cwd().openDir(folder, .{ .iterate = true })) |dir| {
            const pngs = getAllFilesOfType(upaya.mem.allocator, dir, ".png", true);
            const frames = getFramesForPngs(pngs);
            if (runRectPacker(frames)) |atlas_size| {
                std.debug.print("fit in: {}\n", .{atlas_size});
                return Atlas.init(frames, pngs, atlas_size);
            } else {
                std.debug.print("could not fit\n", .{});
            }
        } else |err| {
            std.debug.print("Error opening dir: {}, err: {}\n", .{ folder, err });
        }

        return null;
    }

    fn getFramesForPngs(pngs: [][]const u8) []stb.stbrp_rect {
        var frames = std.ArrayList(stb.stbrp_rect).init(upaya.mem.allocator);
        for (pngs) |png, i| {
            var w: c_int = undefined;
            var h: c_int = undefined;
            const tex_size = upaya.Texture.getTextureSize(png, &w, &h);
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
        const rects_size = @sizeOf(stb.stbrp_rect) * frames.len;
        const node_count = 4096 * 2;
        var nodes: [node_count]stb.stbrp_node = undefined;

        const texture_sizes = [_][2]c_int{
            [_]c_int{ 256, 256 },   [_]c_int{ 512, 256 },   [_]c_int{ 256, 512 },
            [_]c_int{ 512, 512 },   [_]c_int{ 512, 1024 },  [_]c_int{ 1024, 512 },
            [_]c_int{ 1024, 1024 }, [_]c_int{ 2048, 1024 }, [_]c_int{ 1024, 2048 },
            [_]c_int{ 2048, 2048 }, [_]c_int{ 4096, 2048 }, [_]c_int{ 4096, 4096 },
        };

        for (texture_sizes) |tex_size| {
            stb.stbrp_init_target(&ctx, tex_size[0], tex_size[1], &nodes, node_count);
            stb.stbrp_setup_heuristic(&ctx, stb.STBRP_HEURISTIC_Skyline_default);
            if (stb.stbrp_pack_rects(&ctx, frames.ptr, @intCast(c_int, frames.len)) == 1) {
                return Size{ .width = @intCast(u16, tex_size[0]), .height = @intCast(u16, tex_size[0]) };
            }
        }

        return null;
    }
};
