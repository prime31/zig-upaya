// sokol imgui
pub const simgui_desc_t = extern struct {
    max_vertices: c_int,
    color_format: sg_pixel_format,
    depth_format: sg_pixel_format,
    sample_count: c_int,
    dpi_scale: f32,
    ini_filename: [*c]const u8,
    no_default_font: bool,
    disable_hotkeys: bool,
};

pub extern fn simgui_setup(desc: [*c]const simgui_desc_t) void;
pub extern fn simgui_new_frame(width: c_int, height: c_int, delta_time: f64) void;
pub extern fn simgui_render() void;
pub extern fn simgui_handle_event(ev: [*c]const sapp_event) bool;
pub extern fn simgui_shutdown() void;

// sokol glue
pub extern fn sapp_sgcontext() sg_context_desc;

pub usingnamespace @cImport({
    @cDefine("SOKOL_GLCORE33", "");
    @cInclude("sokol/sokol_app.h");
    @cInclude("sokol/sokol_gfx.h");
});
