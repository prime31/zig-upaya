const std = @import("std");
const upaya = @import("upaya.zig");

/// Image is a CPU side array of color data with some helper methods that can be used to prep data
/// before creating a Texture
pub const Image = struct {
    w: usize = 0,
    h: usize = 0,
    pixels: []u32,

    pub fn init(width: usize, height: usize) Image {
        return .{ .w = width, .h = height, .pixels = upaya.mem.allocator.alloc(u32, width * height) catch unreachable };
    }

    pub fn initFromFile(file: []const u8) Image {
        const image_contents = upaya.fs.read(upaya.mem.tmp_allocator, file) catch unreachable;

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = upaya.stb.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, 4);
        if (load_res == null) unreachable;
        defer upaya.stb.stbi_image_free(load_res);

        var img = init(@intCast(usize, w), @intCast(usize, h));
        var pixels = std.mem.bytesAsSlice(u32, load_res[0..@intCast(usize, w * h * channels)]);
        for (pixels) |p, i| {
            img.pixels[i] = p;
        }

        return img;
    }

    pub fn deinit(self: Image) void {
        upaya.mem.allocator.free(self.pixels);
    }

    pub fn fillRect(self: *Image, rect: upaya.math.RectI, color: upaya.math.Color) void {
        const x = @intCast(usize, rect.x);
        var y = @intCast(usize, rect.y);
        const w = @intCast(usize, rect.w);
        var h = @intCast(usize, rect.h);

        var data = self.pixels[x + y * self.w ..];
        while (h > 0) : (h -= 1) {
            var i: usize = 0;
            while (i < w) : (i += 1) {
                data[i] = color.value;
            }

            y += 1;
            data = self.pixels[x + y * self.w ..];
        }
    }

    pub fn blit(self: *Image, src: Image, x: usize, y: usize) void {
        var yy = y;
        var h = src.h;

        var data = self.pixels[x + yy * self.w ..];
        var src_y: usize = 0;
        while (h > 0) : (h -= 1) {
            const src_row = src.pixels[src_y * src.w .. (src_y * src.w) + src.w];
            std.mem.copy(u32, data, src_row);

            // next row and move our slice to it as well
            src_y += 1;
            yy += 1;
            data = self.pixels[x + yy * self.w ..];
        }
    }

    pub fn asTexture(self: Image, filter: upaya.Texture.Filter) upaya.Texture {
        return upaya.Texture.initWithColorData(self.pixels, @intCast(i32, self.w), @intCast(i32, self.h), filter);
    }

    pub fn save(self: Image, file: []const u8) void {
        var c_file = std.cstr.addNullByte(upaya.mem.tmp_allocator, file) catch unreachable;
        var bytes = std.mem.sliceAsBytes(self.pixels);
        _ = upaya.stb.stbi_write_png(c_file.ptr, @intCast(c_int, self.w), @intCast(c_int, self.h), 4, bytes.ptr, @intCast(c_int, self.w * 4));
    }
};
