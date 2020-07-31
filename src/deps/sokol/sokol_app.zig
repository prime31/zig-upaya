pub extern fn sokol_main(argc: c_int, argv: [*c][*c]u8) sapp_desc;
pub extern fn sapp_isvalid() bool;
pub extern fn sapp_width() c_int;
pub extern fn sapp_height() c_int;
pub extern fn sapp_color_format() c_int;
pub extern fn sapp_depth_format() c_int;
pub extern fn sapp_sample_count() c_int;
pub extern fn sapp_high_dpi() bool;
pub extern fn sapp_dpi_scale() f32;
pub extern fn sapp_show_keyboard(visible: bool) void;
pub extern fn sapp_keyboard_shown() bool;
pub extern fn sapp_is_fullscreen() bool;
pub extern fn sapp_toggle_fullscreen() void;
pub extern fn sapp_show_mouse(visible: bool) void;
pub extern fn sapp_mouse_shown(...) bool;
pub extern fn sapp_userdata() ?*c_void;
pub extern fn sapp_query_desc() sapp_desc;
pub extern fn sapp_request_quit() void;
pub extern fn sapp_cancel_quit() void;
pub extern fn sapp_quit() void;
pub extern fn sapp_consume_event() void;
pub extern fn sapp_frame_count() u64;
pub extern fn sapp_set_clipboard_string(str: [*c]const u8) void;
pub extern fn sapp_get_clipboard_string() [*c]const u8;
pub extern fn sapp_get_num_dropped_files() c_int;
pub extern fn sapp_get_dropped_file_path(index: c_int) [*c]const u8;
pub extern fn sapp_run(desc: [*c]const sapp_desc) c_int;
pub extern fn sapp_gles2() bool;
pub extern fn sapp_html5_ask_leave_site(ask: bool) void;
pub extern fn sapp_metal_get_device() ?*const c_void;
pub extern fn sapp_metal_get_renderpass_descriptor() ?*const c_void;
pub extern fn sapp_metal_get_drawable() ?*const c_void;
pub extern fn sapp_macos_get_window() ?*const c_void;
pub extern fn sapp_ios_get_window() ?*const c_void;
pub extern fn sapp_d3d11_get_device() ?*const c_void;
pub extern fn sapp_d3d11_get_device_context() ?*const c_void;
pub extern fn sapp_d3d11_get_render_target_view() ?*const c_void;
pub extern fn sapp_d3d11_get_depth_stencil_view() ?*const c_void;
pub extern fn sapp_win32_get_hwnd() ?*const c_void;
pub extern fn sapp_wgpu_get_device() ?*const c_void;
pub extern fn sapp_wgpu_get_render_view() ?*const c_void;
pub extern fn sapp_wgpu_get_resolve_view() ?*const c_void;
pub extern fn sapp_wgpu_get_depth_stencil_view() ?*const c_void;
pub extern fn sapp_android_get_native_activity() ?*const c_void;

pub const struct_sapp_event = extern struct {
    frame_count: u64,
    type: sapp_event_type,
    key_code: sapp_keycode,
    char_code: u32,
    key_repeat: bool,
    modifiers: u32,
    mouse_button: sapp_mousebutton,
    mouse_x: f32,
    mouse_y: f32,
    scroll_x: f32,
    scroll_y: f32,
    num_touches: c_int,
    touches: [8]sapp_touchpoint,
    window_width: c_int,
    window_height: c_int,
    framebuffer_width: c_int,
    framebuffer_height: c_int,
};
pub const sapp_event = struct_sapp_event;
pub const struct_sapp_desc = extern struct {
    init_cb: ?fn () callconv(.C) void,
    frame_cb: ?fn () callconv(.C) void,
    cleanup_cb: ?fn () callconv(.C) void,
    event_cb: ?fn ([*c]const sapp_event) callconv(.C) void,
    fail_cb: ?fn ([*c]const u8) callconv(.C) void,
    user_data: ?*c_void,
    init_userdata_cb: ?fn (?*c_void) callconv(.C) void,
    frame_userdata_cb: ?fn (?*c_void) callconv(.C) void,
    cleanup_userdata_cb: ?fn (?*c_void) callconv(.C) void,
    event_userdata_cb: ?fn ([*c]const sapp_event, ?*c_void) callconv(.C) void,
    fail_userdata_cb: ?fn ([*c]const u8, ?*c_void) callconv(.C) void,
    width: c_int,
    height: c_int,
    sample_count: c_int,
    swap_interval: c_int,
    high_dpi: bool,
    fullscreen: bool,
    alpha: bool,
    window_title: [*c]const u8,
    user_cursor: bool,
    enable_clipboard: bool,
    clipboard_size: c_int,
    max_dropped_files: c_int,
    max_dropped_file_path_length: c_int,
    html5_canvas_name: [*c]const u8,
    html5_canvas_resize: bool,
    html5_preserve_drawing_buffer: bool,
    html5_premultiplied_alpha: bool,
    html5_ask_leave_site: bool,
    ios_keyboard_resizes_canvas: bool,
    gl_force_gles2: bool,
};
pub const sapp_desc = struct_sapp_desc;

pub const SAPP_MAX_TOUCHPOINTS = @enumToInt(enum_unnamed_2.SAPP_MAX_TOUCHPOINTS);
pub const SAPP_MAX_MOUSEBUTTONS = @enumToInt(enum_unnamed_2.SAPP_MAX_MOUSEBUTTONS);
pub const SAPP_MAX_KEYCODES = @enumToInt(enum_unnamed_2.SAPP_MAX_KEYCODES);
const enum_unnamed_2 = extern enum(c_int) {
    SAPP_MAX_TOUCHPOINTS = 8,
    SAPP_MAX_MOUSEBUTTONS = 3,
    SAPP_MAX_KEYCODES = 512,
    _,
};
pub const SAPP_EVENTTYPE_INVALID = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_INVALID);
pub const SAPP_EVENTTYPE_KEY_DOWN = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_KEY_DOWN);
pub const SAPP_EVENTTYPE_KEY_UP = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_KEY_UP);
pub const SAPP_EVENTTYPE_CHAR = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_CHAR);
pub const SAPP_EVENTTYPE_MOUSE_DOWN = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_MOUSE_DOWN);
pub const SAPP_EVENTTYPE_MOUSE_UP = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_MOUSE_UP);
pub const SAPP_EVENTTYPE_MOUSE_SCROLL = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_MOUSE_SCROLL);
pub const SAPP_EVENTTYPE_MOUSE_MOVE = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_MOUSE_MOVE);
pub const SAPP_EVENTTYPE_MOUSE_ENTER = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_MOUSE_ENTER);
pub const SAPP_EVENTTYPE_MOUSE_LEAVE = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_MOUSE_LEAVE);
pub const SAPP_EVENTTYPE_TOUCHES_BEGAN = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_TOUCHES_BEGAN);
pub const SAPP_EVENTTYPE_TOUCHES_MOVED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_TOUCHES_MOVED);
pub const SAPP_EVENTTYPE_TOUCHES_ENDED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_TOUCHES_ENDED);
pub const SAPP_EVENTTYPE_TOUCHES_CANCELLED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_TOUCHES_CANCELLED);
pub const SAPP_EVENTTYPE_RESIZED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_RESIZED);
pub const SAPP_EVENTTYPE_ICONIFIED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_ICONIFIED);
pub const SAPP_EVENTTYPE_RESTORED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_RESTORED);
pub const SAPP_EVENTTYPE_SUSPENDED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_SUSPENDED);
pub const SAPP_EVENTTYPE_RESUMED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_RESUMED);
pub const SAPP_EVENTTYPE_UPDATE_CURSOR = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_UPDATE_CURSOR);
pub const SAPP_EVENTTYPE_QUIT_REQUESTED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_QUIT_REQUESTED);
pub const SAPP_EVENTTYPE_CLIPBOARD_PASTED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_CLIPBOARD_PASTED);
pub const SAPP_EVENTTYPE_FILE_DROPPED = @enumToInt(enum_sapp_event_type.SAPP_EVENTTYPE_FILE_DROPPED);
pub const _SAPP_EVENTTYPE_NUM = @enumToInt(enum_sapp_event_type._SAPP_EVENTTYPE_NUM);
pub const _SAPP_EVENTTYPE_FORCE_U32 = @enumToInt(enum_sapp_event_type._SAPP_EVENTTYPE_FORCE_U32);
pub const enum_sapp_event_type = extern enum(c_int) {
    SAPP_EVENTTYPE_INVALID = 0,
    SAPP_EVENTTYPE_KEY_DOWN = 1,
    SAPP_EVENTTYPE_KEY_UP = 2,
    SAPP_EVENTTYPE_CHAR = 3,
    SAPP_EVENTTYPE_MOUSE_DOWN = 4,
    SAPP_EVENTTYPE_MOUSE_UP = 5,
    SAPP_EVENTTYPE_MOUSE_SCROLL = 6,
    SAPP_EVENTTYPE_MOUSE_MOVE = 7,
    SAPP_EVENTTYPE_MOUSE_ENTER = 8,
    SAPP_EVENTTYPE_MOUSE_LEAVE = 9,
    SAPP_EVENTTYPE_TOUCHES_BEGAN = 10,
    SAPP_EVENTTYPE_TOUCHES_MOVED = 11,
    SAPP_EVENTTYPE_TOUCHES_ENDED = 12,
    SAPP_EVENTTYPE_TOUCHES_CANCELLED = 13,
    SAPP_EVENTTYPE_RESIZED = 14,
    SAPP_EVENTTYPE_ICONIFIED = 15,
    SAPP_EVENTTYPE_RESTORED = 16,
    SAPP_EVENTTYPE_SUSPENDED = 17,
    SAPP_EVENTTYPE_RESUMED = 18,
    SAPP_EVENTTYPE_UPDATE_CURSOR = 19,
    SAPP_EVENTTYPE_QUIT_REQUESTED = 20,
    SAPP_EVENTTYPE_CLIPBOARD_PASTED = 21,
    SAPP_EVENTTYPE_FILE_DROPPED = 22,
    _SAPP_EVENTTYPE_NUM = 23,
    _SAPP_EVENTTYPE_FORCE_U32 = 2147483647,
    _,
};
pub const sapp_event_type = enum_sapp_event_type;
pub const SAPP_KEYCODE_INVALID = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_INVALID);
pub const SAPP_KEYCODE_SPACE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_SPACE);
pub const SAPP_KEYCODE_APOSTROPHE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_APOSTROPHE);
pub const SAPP_KEYCODE_COMMA = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_COMMA);
pub const SAPP_KEYCODE_MINUS = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_MINUS);
pub const SAPP_KEYCODE_PERIOD = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_PERIOD);
pub const SAPP_KEYCODE_SLASH = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_SLASH);
pub const SAPP_KEYCODE_0 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_0);
pub const SAPP_KEYCODE_1 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_1);
pub const SAPP_KEYCODE_2 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_2);
pub const SAPP_KEYCODE_3 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_3);
pub const SAPP_KEYCODE_4 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_4);
pub const SAPP_KEYCODE_5 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_5);
pub const SAPP_KEYCODE_6 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_6);
pub const SAPP_KEYCODE_7 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_7);
pub const SAPP_KEYCODE_8 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_8);
pub const SAPP_KEYCODE_9 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_9);
pub const SAPP_KEYCODE_SEMICOLON = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_SEMICOLON);
pub const SAPP_KEYCODE_EQUAL = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_EQUAL);
pub const SAPP_KEYCODE_A = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_A);
pub const SAPP_KEYCODE_B = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_B);
pub const SAPP_KEYCODE_C = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_C);
pub const SAPP_KEYCODE_D = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_D);
pub const SAPP_KEYCODE_E = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_E);
pub const SAPP_KEYCODE_F = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F);
pub const SAPP_KEYCODE_G = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_G);
pub const SAPP_KEYCODE_H = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_H);
pub const SAPP_KEYCODE_I = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_I);
pub const SAPP_KEYCODE_J = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_J);
pub const SAPP_KEYCODE_K = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_K);
pub const SAPP_KEYCODE_L = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_L);
pub const SAPP_KEYCODE_M = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_M);
pub const SAPP_KEYCODE_N = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_N);
pub const SAPP_KEYCODE_O = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_O);
pub const SAPP_KEYCODE_P = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_P);
pub const SAPP_KEYCODE_Q = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_Q);
pub const SAPP_KEYCODE_R = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_R);
pub const SAPP_KEYCODE_S = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_S);
pub const SAPP_KEYCODE_T = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_T);
pub const SAPP_KEYCODE_U = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_U);
pub const SAPP_KEYCODE_V = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_V);
pub const SAPP_KEYCODE_W = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_W);
pub const SAPP_KEYCODE_X = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_X);
pub const SAPP_KEYCODE_Y = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_Y);
pub const SAPP_KEYCODE_Z = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_Z);
pub const SAPP_KEYCODE_LEFT_BRACKET = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_LEFT_BRACKET);
pub const SAPP_KEYCODE_BACKSLASH = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_BACKSLASH);
pub const SAPP_KEYCODE_RIGHT_BRACKET = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_RIGHT_BRACKET);
pub const SAPP_KEYCODE_GRAVE_ACCENT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_GRAVE_ACCENT);
pub const SAPP_KEYCODE_WORLD_1 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_WORLD_1);
pub const SAPP_KEYCODE_WORLD_2 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_WORLD_2);
pub const SAPP_KEYCODE_ESCAPE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_ESCAPE);
pub const SAPP_KEYCODE_ENTER = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_ENTER);
pub const SAPP_KEYCODE_TAB = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_TAB);
pub const SAPP_KEYCODE_BACKSPACE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_BACKSPACE);
pub const SAPP_KEYCODE_INSERT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_INSERT);
pub const SAPP_KEYCODE_DELETE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_DELETE);
pub const SAPP_KEYCODE_RIGHT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_RIGHT);
pub const SAPP_KEYCODE_LEFT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_LEFT);
pub const SAPP_KEYCODE_DOWN = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_DOWN);
pub const SAPP_KEYCODE_UP = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_UP);
pub const SAPP_KEYCODE_PAGE_UP = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_PAGE_UP);
pub const SAPP_KEYCODE_PAGE_DOWN = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_PAGE_DOWN);
pub const SAPP_KEYCODE_HOME = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_HOME);
pub const SAPP_KEYCODE_END = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_END);
pub const SAPP_KEYCODE_CAPS_LOCK = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_CAPS_LOCK);
pub const SAPP_KEYCODE_SCROLL_LOCK = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_SCROLL_LOCK);
pub const SAPP_KEYCODE_NUM_LOCK = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_NUM_LOCK);
pub const SAPP_KEYCODE_PRINT_SCREEN = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_PRINT_SCREEN);
pub const SAPP_KEYCODE_PAUSE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_PAUSE);
pub const SAPP_KEYCODE_F1 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F1);
pub const SAPP_KEYCODE_F2 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F2);
pub const SAPP_KEYCODE_F3 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F3);
pub const SAPP_KEYCODE_F4 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F4);
pub const SAPP_KEYCODE_F5 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F5);
pub const SAPP_KEYCODE_F6 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F6);
pub const SAPP_KEYCODE_F7 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F7);
pub const SAPP_KEYCODE_F8 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F8);
pub const SAPP_KEYCODE_F9 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F9);
pub const SAPP_KEYCODE_F10 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F10);
pub const SAPP_KEYCODE_F11 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F11);
pub const SAPP_KEYCODE_F12 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F12);
pub const SAPP_KEYCODE_F13 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F13);
pub const SAPP_KEYCODE_F14 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F14);
pub const SAPP_KEYCODE_F15 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F15);
pub const SAPP_KEYCODE_F16 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F16);
pub const SAPP_KEYCODE_F17 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F17);
pub const SAPP_KEYCODE_F18 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F18);
pub const SAPP_KEYCODE_F19 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F19);
pub const SAPP_KEYCODE_F20 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F20);
pub const SAPP_KEYCODE_F21 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F21);
pub const SAPP_KEYCODE_F22 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F22);
pub const SAPP_KEYCODE_F23 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F23);
pub const SAPP_KEYCODE_F24 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F24);
pub const SAPP_KEYCODE_F25 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_F25);
pub const SAPP_KEYCODE_KP_0 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_0);
pub const SAPP_KEYCODE_KP_1 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_1);
pub const SAPP_KEYCODE_KP_2 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_2);
pub const SAPP_KEYCODE_KP_3 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_3);
pub const SAPP_KEYCODE_KP_4 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_4);
pub const SAPP_KEYCODE_KP_5 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_5);
pub const SAPP_KEYCODE_KP_6 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_6);
pub const SAPP_KEYCODE_KP_7 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_7);
pub const SAPP_KEYCODE_KP_8 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_8);
pub const SAPP_KEYCODE_KP_9 = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_9);
pub const SAPP_KEYCODE_KP_DECIMAL = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_DECIMAL);
pub const SAPP_KEYCODE_KP_DIVIDE = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_DIVIDE);
pub const SAPP_KEYCODE_KP_MULTIPLY = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_MULTIPLY);
pub const SAPP_KEYCODE_KP_SUBTRACT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_SUBTRACT);
pub const SAPP_KEYCODE_KP_ADD = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_ADD);
pub const SAPP_KEYCODE_KP_ENTER = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_ENTER);
pub const SAPP_KEYCODE_KP_EQUAL = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_KP_EQUAL);
pub const SAPP_KEYCODE_LEFT_SHIFT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_LEFT_SHIFT);
pub const SAPP_KEYCODE_LEFT_CONTROL = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_LEFT_CONTROL);
pub const SAPP_KEYCODE_LEFT_ALT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_LEFT_ALT);
pub const SAPP_KEYCODE_LEFT_SUPER = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_LEFT_SUPER);
pub const SAPP_KEYCODE_RIGHT_SHIFT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_RIGHT_SHIFT);
pub const SAPP_KEYCODE_RIGHT_CONTROL = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_RIGHT_CONTROL);
pub const SAPP_KEYCODE_RIGHT_ALT = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_RIGHT_ALT);
pub const SAPP_KEYCODE_RIGHT_SUPER = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_RIGHT_SUPER);
pub const SAPP_KEYCODE_MENU = @enumToInt(enum_sapp_keycode.SAPP_KEYCODE_MENU);
pub const enum_sapp_keycode = extern enum(c_int) {
    SAPP_KEYCODE_INVALID = 0,
    SAPP_KEYCODE_SPACE = 32,
    SAPP_KEYCODE_APOSTROPHE = 39,
    SAPP_KEYCODE_COMMA = 44,
    SAPP_KEYCODE_MINUS = 45,
    SAPP_KEYCODE_PERIOD = 46,
    SAPP_KEYCODE_SLASH = 47,
    SAPP_KEYCODE_0 = 48,
    SAPP_KEYCODE_1 = 49,
    SAPP_KEYCODE_2 = 50,
    SAPP_KEYCODE_3 = 51,
    SAPP_KEYCODE_4 = 52,
    SAPP_KEYCODE_5 = 53,
    SAPP_KEYCODE_6 = 54,
    SAPP_KEYCODE_7 = 55,
    SAPP_KEYCODE_8 = 56,
    SAPP_KEYCODE_9 = 57,
    SAPP_KEYCODE_SEMICOLON = 59,
    SAPP_KEYCODE_EQUAL = 61,
    SAPP_KEYCODE_A = 65,
    SAPP_KEYCODE_B = 66,
    SAPP_KEYCODE_C = 67,
    SAPP_KEYCODE_D = 68,
    SAPP_KEYCODE_E = 69,
    SAPP_KEYCODE_F = 70,
    SAPP_KEYCODE_G = 71,
    SAPP_KEYCODE_H = 72,
    SAPP_KEYCODE_I = 73,
    SAPP_KEYCODE_J = 74,
    SAPP_KEYCODE_K = 75,
    SAPP_KEYCODE_L = 76,
    SAPP_KEYCODE_M = 77,
    SAPP_KEYCODE_N = 78,
    SAPP_KEYCODE_O = 79,
    SAPP_KEYCODE_P = 80,
    SAPP_KEYCODE_Q = 81,
    SAPP_KEYCODE_R = 82,
    SAPP_KEYCODE_S = 83,
    SAPP_KEYCODE_T = 84,
    SAPP_KEYCODE_U = 85,
    SAPP_KEYCODE_V = 86,
    SAPP_KEYCODE_W = 87,
    SAPP_KEYCODE_X = 88,
    SAPP_KEYCODE_Y = 89,
    SAPP_KEYCODE_Z = 90,
    SAPP_KEYCODE_LEFT_BRACKET = 91,
    SAPP_KEYCODE_BACKSLASH = 92,
    SAPP_KEYCODE_RIGHT_BRACKET = 93,
    SAPP_KEYCODE_GRAVE_ACCENT = 96,
    SAPP_KEYCODE_WORLD_1 = 161,
    SAPP_KEYCODE_WORLD_2 = 162,
    SAPP_KEYCODE_ESCAPE = 256,
    SAPP_KEYCODE_ENTER = 257,
    SAPP_KEYCODE_TAB = 258,
    SAPP_KEYCODE_BACKSPACE = 259,
    SAPP_KEYCODE_INSERT = 260,
    SAPP_KEYCODE_DELETE = 261,
    SAPP_KEYCODE_RIGHT = 262,
    SAPP_KEYCODE_LEFT = 263,
    SAPP_KEYCODE_DOWN = 264,
    SAPP_KEYCODE_UP = 265,
    SAPP_KEYCODE_PAGE_UP = 266,
    SAPP_KEYCODE_PAGE_DOWN = 267,
    SAPP_KEYCODE_HOME = 268,
    SAPP_KEYCODE_END = 269,
    SAPP_KEYCODE_CAPS_LOCK = 280,
    SAPP_KEYCODE_SCROLL_LOCK = 281,
    SAPP_KEYCODE_NUM_LOCK = 282,
    SAPP_KEYCODE_PRINT_SCREEN = 283,
    SAPP_KEYCODE_PAUSE = 284,
    SAPP_KEYCODE_F1 = 290,
    SAPP_KEYCODE_F2 = 291,
    SAPP_KEYCODE_F3 = 292,
    SAPP_KEYCODE_F4 = 293,
    SAPP_KEYCODE_F5 = 294,
    SAPP_KEYCODE_F6 = 295,
    SAPP_KEYCODE_F7 = 296,
    SAPP_KEYCODE_F8 = 297,
    SAPP_KEYCODE_F9 = 298,
    SAPP_KEYCODE_F10 = 299,
    SAPP_KEYCODE_F11 = 300,
    SAPP_KEYCODE_F12 = 301,
    SAPP_KEYCODE_F13 = 302,
    SAPP_KEYCODE_F14 = 303,
    SAPP_KEYCODE_F15 = 304,
    SAPP_KEYCODE_F16 = 305,
    SAPP_KEYCODE_F17 = 306,
    SAPP_KEYCODE_F18 = 307,
    SAPP_KEYCODE_F19 = 308,
    SAPP_KEYCODE_F20 = 309,
    SAPP_KEYCODE_F21 = 310,
    SAPP_KEYCODE_F22 = 311,
    SAPP_KEYCODE_F23 = 312,
    SAPP_KEYCODE_F24 = 313,
    SAPP_KEYCODE_F25 = 314,
    SAPP_KEYCODE_KP_0 = 320,
    SAPP_KEYCODE_KP_1 = 321,
    SAPP_KEYCODE_KP_2 = 322,
    SAPP_KEYCODE_KP_3 = 323,
    SAPP_KEYCODE_KP_4 = 324,
    SAPP_KEYCODE_KP_5 = 325,
    SAPP_KEYCODE_KP_6 = 326,
    SAPP_KEYCODE_KP_7 = 327,
    SAPP_KEYCODE_KP_8 = 328,
    SAPP_KEYCODE_KP_9 = 329,
    SAPP_KEYCODE_KP_DECIMAL = 330,
    SAPP_KEYCODE_KP_DIVIDE = 331,
    SAPP_KEYCODE_KP_MULTIPLY = 332,
    SAPP_KEYCODE_KP_SUBTRACT = 333,
    SAPP_KEYCODE_KP_ADD = 334,
    SAPP_KEYCODE_KP_ENTER = 335,
    SAPP_KEYCODE_KP_EQUAL = 336,
    SAPP_KEYCODE_LEFT_SHIFT = 340,
    SAPP_KEYCODE_LEFT_CONTROL = 341,
    SAPP_KEYCODE_LEFT_ALT = 342,
    SAPP_KEYCODE_LEFT_SUPER = 343,
    SAPP_KEYCODE_RIGHT_SHIFT = 344,
    SAPP_KEYCODE_RIGHT_CONTROL = 345,
    SAPP_KEYCODE_RIGHT_ALT = 346,
    SAPP_KEYCODE_RIGHT_SUPER = 347,
    SAPP_KEYCODE_MENU = 348,
    _,
};
pub const sapp_keycode = enum_sapp_keycode;
pub const struct_sapp_touchpoint = extern struct {
    identifier: usize,
    pos_x: f32,
    pos_y: f32,
    changed: bool,
};
pub const sapp_touchpoint = struct_sapp_touchpoint;
pub const SAPP_MOUSEBUTTON_INVALID = @enumToInt(enum_sapp_mousebutton.SAPP_MOUSEBUTTON_INVALID);
pub const SAPP_MOUSEBUTTON_LEFT = @enumToInt(enum_sapp_mousebutton.SAPP_MOUSEBUTTON_LEFT);
pub const SAPP_MOUSEBUTTON_RIGHT = @enumToInt(enum_sapp_mousebutton.SAPP_MOUSEBUTTON_RIGHT);
pub const SAPP_MOUSEBUTTON_MIDDLE = @enumToInt(enum_sapp_mousebutton.SAPP_MOUSEBUTTON_MIDDLE);
pub const enum_sapp_mousebutton = extern enum(c_int) {
    SAPP_MOUSEBUTTON_INVALID = -1,
    SAPP_MOUSEBUTTON_LEFT = 0,
    SAPP_MOUSEBUTTON_RIGHT = 1,
    SAPP_MOUSEBUTTON_MIDDLE = 2,
    _,
};
pub const sapp_mousebutton = enum_sapp_mousebutton;
pub const SAPP_MODIFIER_SHIFT = @enumToInt(enum_unnamed_3.SAPP_MODIFIER_SHIFT);
pub const SAPP_MODIFIER_CTRL = @enumToInt(enum_unnamed_3.SAPP_MODIFIER_CTRL);
pub const SAPP_MODIFIER_ALT = @enumToInt(enum_unnamed_3.SAPP_MODIFIER_ALT);
pub const SAPP_MODIFIER_SUPER = @enumToInt(enum_unnamed_3.SAPP_MODIFIER_SUPER);
const enum_unnamed_3 = extern enum(c_int) {
    SAPP_MODIFIER_SHIFT = 1,
    SAPP_MODIFIER_CTRL = 2,
    SAPP_MODIFIER_ALT = 4,
    SAPP_MODIFIER_SUPER = 8,
    _,
};
