const std = @import("std");
const upaya = @import("upaya.zig");
usingnamespace upaya.sokol;

pub const Texture = extern struct {
    img: sg_image = undefined,
    width: i32 = 0,
    height: i32 = 0,

    pub fn initFromData(pixels: []u8, width: i32, height: i32) Texture {
        var img_desc = std.mem.zeroes(sg_image_desc);
        img_desc.width = width;
        img_desc.height = height;
        img_desc.pixel_format = .SG_PIXELFORMAT_RGBA8;
        img_desc.wrap_u = .SG_WRAP_CLAMP_TO_EDGE;
        img_desc.wrap_v = .SG_WRAP_CLAMP_TO_EDGE;
        img_desc.min_filter = .SG_FILTER_LINEAR; // .SG_FILTER_NEAREST
        img_desc.mag_filter = .SG_FILTER_LINEAR;
        img_desc.content.subimage[0][0].ptr = pixels.ptr;
        img_desc.content.subimage[0][0].size = width * height * 4 * @sizeOf(u8);
        img_desc.label = "upaya-texture";

        return .{ .width = width, .height = height, .img = sg_make_image(&img_desc) };
    }

    pub fn initFromFile(file: []const u8) !Texture {
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = upaya.stb_image.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, 4);
        if (load_res == 0) return error.ImageLoadFailed;

        return Texture.initFromData(image_contents, w, h);
    }

    pub fn deinit(self: Texture) void {
        sg_destroy_image(self.img);
    }

    pub fn imTextureID(self: Texture) upaya.imgui.ImTextureID {
        return @intToPtr(*c_void, self.img.id);
    }

    /// returns true if the image was loaded successfully
    pub fn getTextureSize(file: []const u8, w: *c_int, h: *c_int) bool {
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;
        var comp: c_int = undefined;
        if (upaya.stb_image.stbi_info_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), w, h, &comp) == 1) {
            return true;
        }

        return false;
    }
};
