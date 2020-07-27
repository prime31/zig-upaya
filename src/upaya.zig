const std = @import("std");

// libs
pub const sokol = @import("sokol");
pub const stb_image = @import("stb_image");
pub const imgui = @import("imgui");
pub const filebrowser = @import("filebrowser");

// types
pub const Texture = @import("texture.zig").Texture;

// namespaces
pub const mem = @import("mem/mem.zig");
pub const fs = @import("fs.zig");

usingnamespace sokol;
usingnamespace imgui;

pub const Config = struct {
    init: fn () void,
    update: fn () void,
    shutdown: ?fn () void = null,
    /// optional, will be called if there is no previous dock layout setup with the id of the main dockspace node
    setupDockLayout: ?fn (ImGuiID) void = null,

    width: c_int = 1024,
    height: c_int = 768,
    swap_interval: c_int = 2,
    high_dpi: bool = false,
    fullscreen: bool = false,
    window_title: [*c]const u8 = "upaya",
    enable_clipboard: bool = true,
    clipboard_size: c_int = 4096,

    icon_font: bool = true,
    docking: bool = true,
    dark_style: bool = false,
};

var state = struct {
    config: Config = undefined,
    pass_action: sg_pass_action = undefined,
}{};

pub fn run(config: Config) void {
    state.config = config;

    var app_desc = std.mem.zeroes(sokol.sapp_desc);
    app_desc.init_cb = init;
    app_desc.frame_cb = update;
    app_desc.cleanup_cb = cleanup;
    app_desc.event_cb = event;

    app_desc.width = config.width;
    app_desc.height = config.height;
    app_desc.swap_interval = config.swap_interval;
    app_desc.high_dpi = config.high_dpi;
    app_desc.window_title = config.window_title;
    app_desc.enable_clipboard = config.enable_clipboard;
    app_desc.clipboard_size = config.clipboard_size;
    _ = sokol.sapp_run(&app_desc);
}

// Event functions
export fn init() void {
    mem.initTmpAllocator();

    var desc = std.mem.zeroes(sg_desc);
    desc.context = sapp_sgcontext();
    sokol.sg_setup(&desc);

    var imgui_desc = std.mem.zeroes(simgui_desc_t);
    imgui_desc.no_default_font = true;
    sokol.simgui_setup(&imgui_desc);

    var io = igGetIO();
    if (state.config.docking) io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    io.ConfigDockingWithShift = true;

    if (state.config.dark_style) {
        igStyleColorsDark(igGetStyle());
    }

    igGetStyle().FrameRounding = 0;
    igGetStyle().WindowRounding = 0;

    loadDefaultFont();

    state.pass_action.colors[0].action = .SG_ACTION_CLEAR;
    state.pass_action.colors[0].val = [_]f32{ 0.2, 0.2, 0.2, 1.0 };

    state.config.init();
}

export fn update() void {
    const width = sapp_width();
    const height = sapp_height();
    simgui_new_frame(width, height, 0.017);

    if (state.config.docking) beginDock();
    state.config.update();
    if (state.config.docking) igEnd();

    sg_begin_default_pass(&state.pass_action, width, height);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

export fn event(e: [*c]const sokol.sapp_event) void {
    _ = simgui_handle_event(e);
}

export fn cleanup() void {
    if (state.config.shutdown) |shutdown| shutdown();
    simgui_shutdown();
    sg_shutdown();
}

// helper functions
fn beginDock() void {
    const vp = igGetMainViewport();
    var work_pos = ImVec2{};
    var work_size = ImVec2{};
    ImGuiViewport_GetWorkPos(&work_pos, vp);
    ImGuiViewport_GetWorkSize(&work_size, vp);

    igSetNextWindowPos(work_pos, ImGuiCond_Always, .{});
    igSetNextWindowSize(work_size, ImGuiCond_Always);
    igSetNextWindowViewport(vp.ID);

    var window_flags = ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_MenuBar;
    window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
    window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;

    igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
    _ = igBegin("Dockspace", null, window_flags);
    igPopStyleVar(1);

    const io = igGetIO();
    const dockspace_id = igGetIDStr("upaya-dockspace");
    // igDockBuilderRemoveNode(dockspace_id); // uncomment for testing initial layout setup code
    if (igDockBuilderGetNode(dockspace_id) == null) {
        if (state.config.setupDockLayout) |setupDockLayout| {
            var dock_main_id = igDockBuilderAddNode(dockspace_id, ImGuiDockNodeFlags_DockSpace);
            igDockBuilderSetNodeSize(dockspace_id, work_size);
            setupDockLayout(dock_main_id);
        }
    }

    igDockSpace(dockspace_id, .{}, ImGuiDockNodeFlags_None, null);
}

const font_awesome_range: [3]ImWchar = [_]ImWchar{ icons.icon_range_min, icons.icon_range_max, 0 };

fn loadDefaultFont() void {
    var io = igGetIO();
    _ = ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add FontAwesome optionally
    if (state.config.icon_font) {
        var icons_config = ImFontConfig_ImFontConfig();
        icons_config[0].MergeMode = true;
        icons_config[0].PixelSnapH = true;
        icons_config[0].FontDataOwnedByAtlas = false;

        var data = @embedFile("assets/" ++ icons.font_icon_filename_fas);
        _ = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, &font_awesome_range[0]);
    }

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = Texture.initFromData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h);
    ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}

pub fn loadTexture(pixels: []u8, width: i32, height: i32) sg_image {
    var img_desc = std.mem.zeroes(sg_image_desc);
    img_desc.width = width;
    img_desc.height = height;
    img_desc.pixel_format = .SG_PIXELFORMAT_RGBA8;
    img_desc.wrap_u = .SG_WRAP_CLAMP_TO_EDGE;
    img_desc.wrap_v = .SG_WRAP_CLAMP_TO_EDGE;
    img_desc.min_filter = .SG_FILTER_LINEAR;
    img_desc.mag_filter = .SG_FILTER_LINEAR;
    img_desc.content.subimage[0][0].ptr = pixels.ptr;
    img_desc.content.subimage[0][0].size = width * height * 4 * @sizeOf(u8);
    img_desc.label = "upaya-texture";

    return sg_make_image(&img_desc);
}
