// sokol imgui
pub const simgui_desc_t = extern struct {
    max_vertices: c_int,
    color_format: Self.sg_pixel_format,
    depth_format: Self.sg_pixel_format,
    sample_count: c_int,
    dpi_scale: f32,
    ini_filename: [*c]const u8,
    no_default_font: bool,
    disable_hotkeys: bool,
};

pub extern fn simgui_setup(desc: [*c]const simgui_desc_t) void;
pub extern fn simgui_new_frame(width: c_int, height: c_int, delta_time: f64) void;
pub extern fn simgui_render() void;
pub extern fn simgui_handle_event(ev: [*c]const Self.sapp_event) bool;
pub extern fn simgui_shutdown() void;

// sokol glue
pub extern fn sapp_sgcontext() Self.sg_context_desc;

const Self = @This();

// sokol app
pub usingnamespace @import("sokol_app.zig");
pub usingnamespace @import("sokol_gfx.zig");
