pub extern var stbi_write_tga_with_rle: c_int;
pub extern var stbi_write_png_compression_level: c_int;
pub extern var stbi_write_force_png_filter: c_int;

pub extern fn stbi_write_png(filename: [*c]const u8, w: c_int, h: c_int, comp: c_int, data: ?*const anyopaque, stride_in_bytes: c_int) c_int;
pub extern fn stbi_write_bmp(filename: [*c]const u8, w: c_int, h: c_int, comp: c_int, data: ?*const anyopaque) c_int;
pub extern fn stbi_write_tga(filename: [*c]const u8, w: c_int, h: c_int, comp: c_int, data: ?*const anyopaque) c_int;
pub extern fn stbi_write_hdr(filename: [*c]const u8, w: c_int, h: c_int, comp: c_int, data: [*c]const f32) c_int;
pub extern fn stbi_write_jpg(filename: [*c]const u8, x: c_int, y: c_int, comp: c_int, data: ?*const anyopaque, quality: c_int) c_int;

pub const stbi_write_func = fn (?*anyopaque, ?*anyopaque, c_int) callconv(.C) void;
pub extern fn stbi_write_png_to_func(func: ?stbi_write_func, context: ?*anyopaque, w: c_int, h: c_int, comp: c_int, data: ?*const anyopaque, stride_in_bytes: c_int) c_int;
pub extern fn stbi_write_bmp_to_func(func: ?stbi_write_func, context: ?*anyopaque, w: c_int, h: c_int, comp: c_int, data: ?*const anyopaque) c_int;
pub extern fn stbi_write_tga_to_func(func: ?stbi_write_func, context: ?*anyopaque, w: c_int, h: c_int, comp: c_int, data: ?*const anyopaque) c_int;
pub extern fn stbi_write_hdr_to_func(func: ?stbi_write_func, context: ?*anyopaque, w: c_int, h: c_int, comp: c_int, data: [*c]const f32) c_int;
pub extern fn stbi_write_jpg_to_func(func: ?stbi_write_func, context: ?*anyopaque, x: c_int, y: c_int, comp: c_int, data: ?*const anyopaque, quality: c_int) c_int;
pub extern fn stbi_flip_vertically_on_write(flip_boolean: c_int) void;
