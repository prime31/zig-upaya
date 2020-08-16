pub const STBI_default = @enumToInt(enum_unnamed_1.STBI_default);
pub const STBI_grey = @enumToInt(enum_unnamed_1.STBI_grey);
pub const STBI_grey_alpha = @enumToInt(enum_unnamed_1.STBI_grey_alpha);
pub const STBI_rgb = @enumToInt(enum_unnamed_1.STBI_rgb);
pub const STBI_rgb_alpha = @enumToInt(enum_unnamed_1.STBI_rgb_alpha);
const enum_unnamed_1 = extern enum(c_int) {
    STBI_default = 0,
    STBI_grey = 1,
    STBI_grey_alpha = 2,
    STBI_rgb = 3,
    STBI_rgb_alpha = 4,
    _,
};

pub const stbi_uc = u8;
pub const stbi_us = c_ushort;
const struct_unnamed_9 = extern struct {
    read: ?fn (?*c_void, [*c]u8, c_int) callconv(.C) c_int,
    skip: ?fn (?*c_void, c_int) callconv(.C) void,
    eof: ?fn (?*c_void) callconv(.C) c_int,
};
pub const stbi_io_callbacks = struct_unnamed_9;
pub extern fn stbi_load_from_memory(buffer: [*c]const stbi_uc, len: c_int, x: [*c]c_int, y: [*c]c_int, channels_in_file: [*c]c_int, desired_channels: c_int) [*c]stbi_uc;
pub extern fn stbi_load_from_callbacks(clbk: [*c]const stbi_io_callbacks, user: ?*c_void, x: [*c]c_int, y: [*c]c_int, channels_in_file: [*c]c_int, desired_channels: c_int) [*c]stbi_uc;
pub extern fn stbi_load_gif_from_memory(buffer: [*c]const stbi_uc, len: c_int, delays: [*c][*c]c_int, x: [*c]c_int, y: [*c]c_int, z: [*c]c_int, comp: [*c]c_int, req_comp: c_int) [*c]stbi_uc;
pub extern fn stbi_load_16_from_memory(buffer: [*c]const stbi_uc, len: c_int, x: [*c]c_int, y: [*c]c_int, channels_in_file: [*c]c_int, desired_channels: c_int) [*c]stbi_us;
pub extern fn stbi_load_16_from_callbacks(clbk: [*c]const stbi_io_callbacks, user: ?*c_void, x: [*c]c_int, y: [*c]c_int, channels_in_file: [*c]c_int, desired_channels: c_int) [*c]stbi_us;
pub extern fn stbi_loadf_from_memory(buffer: [*c]const stbi_uc, len: c_int, x: [*c]c_int, y: [*c]c_int, channels_in_file: [*c]c_int, desired_channels: c_int) [*c]f32;
pub extern fn stbi_loadf_from_callbacks(clbk: [*c]const stbi_io_callbacks, user: ?*c_void, x: [*c]c_int, y: [*c]c_int, channels_in_file: [*c]c_int, desired_channels: c_int) [*c]f32;
pub extern fn stbi_hdr_to_ldr_gamma(gamma: f32) void;
pub extern fn stbi_hdr_to_ldr_scale(scale: f32) void;
pub extern fn stbi_ldr_to_hdr_gamma(gamma: f32) void;
pub extern fn stbi_ldr_to_hdr_scale(scale: f32) void;
pub extern fn stbi_is_hdr_from_callbacks(clbk: [*c]const stbi_io_callbacks, user: ?*c_void) c_int;
pub extern fn stbi_is_hdr_from_memory(buffer: [*c]const stbi_uc, len: c_int) c_int;
pub extern fn stbi_failure_reason() [*c]const u8;
pub extern fn stbi_image_free(retval_from_stbi_load: ?*c_void) void;
pub extern fn stbi_info_from_memory(buffer: [*c]const stbi_uc, len: c_int, x: [*c]c_int, y: [*c]c_int, comp: [*c]c_int) c_int;
pub extern fn stbi_info_from_callbacks(clbk: [*c]const stbi_io_callbacks, user: ?*c_void, x: [*c]c_int, y: [*c]c_int, comp: [*c]c_int) c_int;
pub extern fn stbi_is_16_bit_from_memory(buffer: [*c]const stbi_uc, len: c_int) c_int;
pub extern fn stbi_is_16_bit_from_callbacks(clbk: [*c]const stbi_io_callbacks, user: ?*c_void) c_int;
pub extern fn stbi_set_unpremultiply_on_load(flag_true_if_should_unpremultiply: c_int) void;
pub extern fn stbi_convert_iphone_png_to_rgb(flag_true_if_should_convert: c_int) void;
pub extern fn stbi_set_flip_vertically_on_load(flag_true_if_should_flip: c_int) void;
pub extern fn stbi_set_flip_vertically_on_load_thread(flag_true_if_should_flip: c_int) void;
pub extern fn stbi_zlib_decode_malloc_guesssize(buffer: [*c]const u8, len: c_int, initial_size: c_int, outlen: [*c]c_int) [*c]u8;
pub extern fn stbi_zlib_decode_malloc_guesssize_headerflag(buffer: [*c]const u8, len: c_int, initial_size: c_int, outlen: [*c]c_int, parse_header: c_int) [*c]u8;
pub extern fn stbi_zlib_decode_malloc(buffer: [*c]const u8, len: c_int, outlen: [*c]c_int) [*c]u8;
pub extern fn stbi_zlib_decode_buffer(obuffer: [*c]u8, olen: c_int, ibuffer: [*c]const u8, ilen: c_int) c_int;
pub extern fn stbi_zlib_decode_noheader_malloc(buffer: [*c]const u8, len: c_int, outlen: [*c]c_int) [*c]u8;
pub extern fn stbi_zlib_decode_noheader_buffer(obuffer: [*c]u8, olen: c_int, ibuffer: [*c]const u8, ilen: c_int) c_int;
