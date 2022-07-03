const std = @import("std");
const builtin = @import("builtin");

// libs
pub const sokol = @import("sokol");
pub const stb = @import("stb");
pub const imgui = @import("imgui");
pub const filebrowser = @import("filebrowser");

// types
pub const TexturePacker = @import("utils/texture_packer.zig").TexturePacker;
pub const Image = @import("image.zig").Image;
pub const Texture = @import("texture.zig").Texture;
pub const RenderTexture = @import("render_texture.zig").RenderTexture;
pub const MenuItem = @import("menu.zig").MenuItem;
pub const FixedList = @import("utils/fixed_list.zig").FixedList;

// namespaces
pub const mem = @import("mem/mem.zig");
pub const fs = @import("fs.zig");
pub const math = @import("math/math.zig");
pub const colors = @import("colors.zig");
pub const menu = @import("menu.zig");
pub const known_folders = @import("utils/known-folders.zig");
pub const tilemaps = @import("tilemaps/tilemaps.zig");

pub const Config = struct {
    init: fn () void,
    update: fn () void,
    shutdown: ?fn () void = null,
    /// optional, will be called if there is no previous dock layout setup with the id of the main dockspace node
    setupDockLayout: ?fn (imgui.ImGuiID) void = null,
    onFileDropped: ?fn ([]const u8) void = null,

    width: c_int = 1024,
    height: c_int = 768,
    swap_interval: c_int = 1,
    high_dpi: bool = false,
    fullscreen: bool = false,
    window_title: [*c]const u8 = "upaya",
    enable_clipboard: bool = true,
    clipboard_size: c_int = 4096,

    /// optionally adds FontAwesome fonts which are accessible via imgui.icons
    icon_font: bool = true,
    docking: bool = true,
    dark_style: bool = false,
    /// how the imgui internal data should be stored. If saved_games_dir is used, app_name MUST be specified!
    ini_file_storage: enum { none, current_dir, saved_games_dir } = .current_dir,
    /// used if ini_file_storage is saved_games_dir as the subfolder in the save games folder
    app_name: ?[]const u8 = null,
};

// private
const font_awesome_range: [3]imgui.ImWchar = [_]imgui.ImWchar{ imgui.icons.icon_range_min, imgui.icons.icon_range_max, 0 };

var state = struct {
    config: Config = undefined,
    pass_action: sokol.sg_pass_action = undefined,
    cmd_down: bool = false,
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

    if (state.config.onFileDropped == null) {
        app_desc.max_dropped_files = 0;
    }

    app_desc.alpha = false;
    _ = sokol.sapp_run(&app_desc);
}

// Event functions
export fn init() void {
    mem.initTmpAllocator() catch return;

    var desc = std.mem.zeroes(sokol.sg_desc);
    desc.context = sokol.sapp_sgcontext();
    sokol.sg_setup(&desc);

    var imgui_desc = std.mem.zeroes(sokol.simgui_desc_t);
    imgui_desc.no_default_font = true;
    imgui_desc.dpi_scale = sokol.sapp_dpi_scale();

    if (state.config.ini_file_storage != .none) {
        if (state.config.ini_file_storage == .current_dir) {
            imgui_desc.ini_filename = "imgui.ini";
        } else {
            std.debug.assert(state.config.app_name != null);
            const path = fs.getSaveGamesFile(state.config.app_name.?, "imgui.ini") catch unreachable;
            imgui_desc.ini_filename = mem.allocator.dupeZ(u8, path) catch unreachable;
        }
    }

    sokol.simgui_setup(&imgui_desc);

    var io = imgui.igGetIO();
    if (state.config.docking) io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
    io.ConfigDockingWithShift = true;

    if (state.config.dark_style) {
        imgui.igStyleColorsDark(imgui.igGetStyle());
    }

    imgui.igGetStyle().FrameRounding = 0;
    imgui.igGetStyle().WindowRounding = 0;

    loadDefaultFont();

    state.pass_action.colors[0].action = .SG_ACTION_CLEAR;
    state.pass_action.colors[0].val = [_]f32{ 0.2, 0.2, 0.2, 1.0 };

    state.config.init();
}

export fn update() void {
    const width = sokol.sapp_width();
    const height = sokol.sapp_height();
    sokol.simgui_new_frame(width, height, 0.017);

    if (state.config.docking) beginDock();
    state.config.update();
    if (state.config.docking) imgui.igEnd();

    sokol.sg_begin_default_pass(&state.pass_action, width, height);
    sokol.simgui_render();
    sokol.sg_end_pass();
    sokol.sg_commit();
}

export fn event(e: [*c]const sokol.sapp_event) void {
    // special handling of dropped files
    if (e[0].type == .SAPP_EVENTTYPE_FILE_DROPPED) {
        if (state.config.onFileDropped) |onFileDropped| {
            const dropped_file_cnt = sokol.sapp_get_num_dropped_files();
            var i: usize = 0;
            while (i < dropped_file_cnt) : (i += 1) {
                onFileDropped(std.mem.span(sokol.sapp_get_dropped_file_path(@intCast(c_int, i))));
            }
        }
    }

    // handle cmd+Q on macos
    if (builtin.os.tag == .macos) {
        if (e[0].type == .SAPP_EVENTTYPE_KEY_DOWN) {
            if (e[0].key_code == .SAPP_KEYCODE_LEFT_SUPER) {
                state.cmd_down = true;
            } else if (state.cmd_down and e[0].key_code == .SAPP_KEYCODE_Q) {
                imgui.sapp_request_quit();
            }
        } else if (e[0].type == .SAPP_EVENTTYPE_KEY_UP and e[0].key_code == .SAPP_KEYCODE_LEFT_SUPER) {
            state.cmd_down = false;
        }
    }

    _ = sokol.simgui_handle_event(e);
}

export fn cleanup() void {
    if (state.config.shutdown) |shutdown| shutdown();
    sokol.simgui_shutdown();
    sokol.sg_shutdown();
}

pub fn quit() void {
    sokol.sapp_request_quit();
}

// helper functions
fn beginDock() void {
    const vp = imgui.igGetMainViewport();
    var work_pos = imgui.ImVec2{};
    var work_size = imgui.ImVec2{};
    imgui.ImGuiViewport_GetWorkPos(&work_pos, vp);
    imgui.ImGuiViewport_GetWorkSize(&work_size, vp);

    imgui.igSetNextWindowPos(work_pos, imgui.ImGuiCond_Always, .{});
    imgui.igSetNextWindowSize(work_size, imgui.ImGuiCond_Always);
    imgui.igSetNextWindowViewport(vp.ID);

    var window_flags = imgui.ImGuiWindowFlags_NoDocking | imgui.ImGuiWindowFlags_MenuBar;
    window_flags |= imgui.ImGuiWindowFlags_NoTitleBar | imgui.ImGuiWindowFlags_NoCollapse | imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_NoMove;
    window_flags |= imgui.ImGuiWindowFlags_NoBringToFrontOnFocus | imgui.ImGuiWindowFlags_NoNavFocus;

    imgui.igPushStyleVarVec2(imgui.ImGuiStyleVar_WindowPadding, .{});
    _ = imgui.igBegin("Dockspace", null, window_flags);
    imgui.igPopStyleVar(1);

    const dockspace_id = imgui.igGetIDStr("upaya-dockspace");
    // igDockBuilderRemoveNode(dockspace_id); // uncomment for testing initial layout setup code
    if (imgui.igDockBuilderGetNode(dockspace_id) == null) {
        if (state.config.setupDockLayout) |setupDockLayout| {
            var dock_main_id = imgui.igDockBuilderAddNode(dockspace_id, imgui.ImGuiDockNodeFlags_DockSpace);
            imgui.ogDockBuilderSetNodeSize(dockspace_id, work_size);
            setupDockLayout(dock_main_id);
        }
    }

    imgui.ogDockSpace(dockspace_id, .{}, imgui.ImGuiDockNodeFlags_None, null);
}

fn loadDefaultFont() void {
    var io = imgui.igGetIO();
    _ = imgui.ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add FontAwesome optionally
    if (state.config.icon_font) {
        var icons_config = imgui.ImFontConfig_ImFontConfig();
        icons_config[0].MergeMode = true;
        icons_config[0].PixelSnapH = true;
        icons_config[0].FontDataOwnedByAtlas = false;

        var data = @embedFile("assets/" ++ imgui.icons.font_icon_filename_fas);
        _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, &font_awesome_range[0]);
    }

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    imgui.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = Texture.initWithData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h, .nearest);
    imgui.ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}
