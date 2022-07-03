pub extern fn sg_setup(desc: [*c]const sg_desc) void;
pub extern fn sg_shutdown() void;
pub extern fn sg_isvalid() bool;
pub extern fn sg_reset_state_cache() void;
pub extern fn sg_install_trace_hooks(trace_hooks: [*c]const sg_trace_hooks) sg_trace_hooks;
pub extern fn sg_push_debug_group(name: [*c]const u8) void;
pub extern fn sg_pop_debug_group() void;
pub extern fn sg_make_buffer(desc: [*c]const sg_buffer_desc) sg_buffer;
pub extern fn sg_make_image(desc: [*c]const sg_image_desc) sg_image;
pub extern fn sg_make_shader(desc: [*c]const sg_shader_desc) sg_shader;
pub extern fn sg_make_pipeline(desc: [*c]const sg_pipeline_desc) sg_pipeline;
pub extern fn sg_make_pass(desc: [*c]const sg_pass_desc) sg_pass;
pub extern fn sg_destroy_buffer(buf: sg_buffer) void;
pub extern fn sg_destroy_image(img: sg_image) void;
pub extern fn sg_destroy_shader(shd: sg_shader) void;
pub extern fn sg_destroy_pipeline(pip: sg_pipeline) void;
pub extern fn sg_destroy_pass(pass: sg_pass) void;
pub extern fn sg_update_buffer(buf: sg_buffer, data_ptr: ?*const anyopaque, data_size: c_int) void;
pub extern fn sg_update_image(img: sg_image, data: [*c]const sg_image_content) void;
pub extern fn sg_append_buffer(buf: sg_buffer, data_ptr: ?*const anyopaque, data_size: c_int) c_int;
pub extern fn sg_query_buffer_overflow(buf: sg_buffer) bool;
pub extern fn sg_begin_default_pass(pass_action: [*c]const sg_pass_action, width: c_int, height: c_int) void;
pub extern fn sg_begin_pass(pass: sg_pass, pass_action: [*c]const sg_pass_action) void;
pub extern fn sg_apply_viewport(x: c_int, y: c_int, width: c_int, height: c_int, origin_top_left: bool) void;
pub extern fn sg_apply_scissor_rect(x: c_int, y: c_int, width: c_int, height: c_int, origin_top_left: bool) void;
pub extern fn sg_apply_pipeline(pip: sg_pipeline) void;
pub extern fn sg_apply_bindings(bindings: [*c]const sg_bindings) void;
pub extern fn sg_apply_uniforms(stage: sg_shader_stage, ub_index: c_int, data: ?*const anyopaque, num_bytes: c_int) void;
pub extern fn sg_draw(base_element: c_int, num_elements: c_int, num_instances: c_int) void;
pub extern fn sg_end_pass() void;
pub extern fn sg_commit() void;
pub extern fn sg_query_desc() sg_desc;
pub extern fn sg_query_backend() sg_backend;
pub extern fn sg_query_features() sg_features;
pub extern fn sg_query_limits() sg_limits;
pub extern fn sg_query_pixelformat(fmt: sg_pixel_format) sg_pixelformat_info;
pub extern fn sg_query_buffer_state(buf: sg_buffer) sg_resource_state;
pub extern fn sg_query_image_state(img: sg_image) sg_resource_state;
pub extern fn sg_query_shader_state(shd: sg_shader) sg_resource_state;
pub extern fn sg_query_pipeline_state(pip: sg_pipeline) sg_resource_state;
pub extern fn sg_query_pass_state(pass: sg_pass) sg_resource_state;
pub extern fn sg_query_buffer_info(buf: sg_buffer) sg_buffer_info;
pub extern fn sg_query_image_info(img: sg_image) sg_image_info;
pub extern fn sg_query_shader_info(shd: sg_shader) sg_shader_info;
pub extern fn sg_query_pipeline_info(pip: sg_pipeline) sg_pipeline_info;
pub extern fn sg_query_pass_info(pass: sg_pass) sg_pass_info;
pub extern fn sg_query_buffer_defaults(desc: [*c]const sg_buffer_desc) sg_buffer_desc;
pub extern fn sg_query_image_defaults(desc: [*c]const sg_image_desc) sg_image_desc;
pub extern fn sg_query_shader_defaults(desc: [*c]const sg_shader_desc) sg_shader_desc;
pub extern fn sg_query_pipeline_defaults(desc: [*c]const sg_pipeline_desc) sg_pipeline_desc;
pub extern fn sg_query_pass_defaults(desc: [*c]const sg_pass_desc) sg_pass_desc;
pub extern fn sg_alloc_buffer() sg_buffer;
pub extern fn sg_alloc_image() sg_image;
pub extern fn sg_alloc_shader() sg_shader;
pub extern fn sg_alloc_pipeline() sg_pipeline;
pub extern fn sg_alloc_pass() sg_pass;
pub extern fn sg_init_buffer(buf_id: sg_buffer, desc: [*c]const sg_buffer_desc) void;
pub extern fn sg_init_image(img_id: sg_image, desc: [*c]const sg_image_desc) void;
pub extern fn sg_init_shader(shd_id: sg_shader, desc: [*c]const sg_shader_desc) void;
pub extern fn sg_init_pipeline(pip_id: sg_pipeline, desc: [*c]const sg_pipeline_desc) void;
pub extern fn sg_init_pass(pass_id: sg_pass, desc: [*c]const sg_pass_desc) void;
pub extern fn sg_fail_buffer(buf_id: sg_buffer) void;
pub extern fn sg_fail_image(img_id: sg_image) void;
pub extern fn sg_fail_shader(shd_id: sg_shader) void;
pub extern fn sg_fail_pipeline(pip_id: sg_pipeline) void;
pub extern fn sg_fail_pass(pass_id: sg_pass) void;
pub extern fn sg_setup_context() sg_context;
pub extern fn sg_activate_context(ctx_id: sg_context) void;
pub extern fn sg_discard_context(ctx_id: sg_context) void;
pub extern fn sg_mtl_render_command_encoder() ?*const anyopaque;

pub const struct_sg_buffer = extern struct {
    id: u32,
};
pub const sg_buffer = struct_sg_buffer;
pub const struct_sg_image = extern struct {
    id: u32,
};
pub const sg_image = struct_sg_image;
pub const struct_sg_shader = extern struct {
    id: u32,
};
pub const sg_shader = struct_sg_shader;
pub const struct_sg_pipeline = extern struct {
    id: u32,
};
pub const sg_pipeline = struct_sg_pipeline;
pub const struct_sg_pass = extern struct {
    id: u32,
};
pub const sg_pass = struct_sg_pass;
pub const struct_sg_context = extern struct {
    id: u32,
};
pub const sg_context = struct_sg_context;
pub const SG_INVALID_ID = @enumToInt(enum_unnamed_2.SG_INVALID_ID);
pub const SG_NUM_SHADER_STAGES = @enumToInt(enum_unnamed_2.SG_NUM_SHADER_STAGES);
pub const SG_NUM_INFLIGHT_FRAMES = @enumToInt(enum_unnamed_2.SG_NUM_INFLIGHT_FRAMES);
pub const SG_MAX_COLOR_ATTACHMENTS = @enumToInt(enum_unnamed_2.SG_MAX_COLOR_ATTACHMENTS);
pub const SG_MAX_SHADERSTAGE_BUFFERS = @enumToInt(enum_unnamed_2.SG_MAX_SHADERSTAGE_BUFFERS);
pub const SG_MAX_SHADERSTAGE_IMAGES = @enumToInt(enum_unnamed_2.SG_MAX_SHADERSTAGE_IMAGES);
pub const SG_MAX_SHADERSTAGE_UBS = @enumToInt(enum_unnamed_2.SG_MAX_SHADERSTAGE_UBS);
pub const SG_MAX_UB_MEMBERS = @enumToInt(enum_unnamed_2.SG_MAX_UB_MEMBERS);
pub const SG_MAX_VERTEX_ATTRIBUTES = @enumToInt(enum_unnamed_2.SG_MAX_VERTEX_ATTRIBUTES);
pub const SG_MAX_MIPMAPS = @enumToInt(enum_unnamed_2.SG_MAX_MIPMAPS);
pub const SG_MAX_TEXTUREARRAY_LAYERS = @enumToInt(enum_unnamed_2.SG_MAX_TEXTUREARRAY_LAYERS);
const enum_unnamed_2 = enum(c_int) {
    SG_INVALID_ID = 0,
    SG_NUM_SHADER_STAGES = 2,
    SG_NUM_INFLIGHT_FRAMES = 2,
    SG_MAX_COLOR_ATTACHMENTS = 4,
    SG_MAX_SHADERSTAGE_BUFFERS = 8,
    SG_MAX_SHADERSTAGE_IMAGES = 12,
    SG_MAX_SHADERSTAGE_UBS = 4,
    SG_MAX_UB_MEMBERS = 16,
    SG_MAX_VERTEX_ATTRIBUTES = 16,
    SG_MAX_MIPMAPS = 16,
    SG_MAX_TEXTUREARRAY_LAYERS = 128,
    _,
};
pub const SG_BACKEND_GLCORE33 = @enumToInt(enum_sg_backend.SG_BACKEND_GLCORE33);
pub const SG_BACKEND_GLES2 = @enumToInt(enum_sg_backend.SG_BACKEND_GLES2);
pub const SG_BACKEND_GLES3 = @enumToInt(enum_sg_backend.SG_BACKEND_GLES3);
pub const SG_BACKEND_D3D11 = @enumToInt(enum_sg_backend.SG_BACKEND_D3D11);
pub const SG_BACKEND_METAL_IOS = @enumToInt(enum_sg_backend.SG_BACKEND_METAL_IOS);
pub const SG_BACKEND_METAL_MACOS = @enumToInt(enum_sg_backend.SG_BACKEND_METAL_MACOS);
pub const SG_BACKEND_METAL_SIMULATOR = @enumToInt(enum_sg_backend.SG_BACKEND_METAL_SIMULATOR);
pub const SG_BACKEND_WGPU = @enumToInt(enum_sg_backend.SG_BACKEND_WGPU);
pub const SG_BACKEND_DUMMY = @enumToInt(enum_sg_backend.SG_BACKEND_DUMMY);
pub const enum_sg_backend = enum(c_int) {
    SG_BACKEND_GLCORE33,
    SG_BACKEND_GLES2,
    SG_BACKEND_GLES3,
    SG_BACKEND_D3D11,
    SG_BACKEND_METAL_IOS,
    SG_BACKEND_METAL_MACOS,
    SG_BACKEND_METAL_SIMULATOR,
    SG_BACKEND_WGPU,
    SG_BACKEND_DUMMY,
    _,
};
pub const sg_backend = enum_sg_backend;
pub const _SG_PIXELFORMAT_DEFAULT = @enumToInt(enum_sg_pixel_format._SG_PIXELFORMAT_DEFAULT);
pub const SG_PIXELFORMAT_NONE = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_NONE);
pub const SG_PIXELFORMAT_R8 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R8);
pub const SG_PIXELFORMAT_R8SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R8SN);
pub const SG_PIXELFORMAT_R8UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R8UI);
pub const SG_PIXELFORMAT_R8SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R8SI);
pub const SG_PIXELFORMAT_R16 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R16);
pub const SG_PIXELFORMAT_R16SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R16SN);
pub const SG_PIXELFORMAT_R16UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R16UI);
pub const SG_PIXELFORMAT_R16SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R16SI);
pub const SG_PIXELFORMAT_R16F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R16F);
pub const SG_PIXELFORMAT_RG8 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG8);
pub const SG_PIXELFORMAT_RG8SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG8SN);
pub const SG_PIXELFORMAT_RG8UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG8UI);
pub const SG_PIXELFORMAT_RG8SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG8SI);
pub const SG_PIXELFORMAT_R32UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R32UI);
pub const SG_PIXELFORMAT_R32SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R32SI);
pub const SG_PIXELFORMAT_R32F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_R32F);
pub const SG_PIXELFORMAT_RG16 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG16);
pub const SG_PIXELFORMAT_RG16SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG16SN);
pub const SG_PIXELFORMAT_RG16UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG16UI);
pub const SG_PIXELFORMAT_RG16SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG16SI);
pub const SG_PIXELFORMAT_RG16F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG16F);
pub const SG_PIXELFORMAT_RGBA8 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA8);
pub const SG_PIXELFORMAT_RGBA8SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA8SN);
pub const SG_PIXELFORMAT_RGBA8UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA8UI);
pub const SG_PIXELFORMAT_RGBA8SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA8SI);
pub const SG_PIXELFORMAT_BGRA8 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BGRA8);
pub const SG_PIXELFORMAT_RGB10A2 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGB10A2);
pub const SG_PIXELFORMAT_RG11B10F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG11B10F);
pub const SG_PIXELFORMAT_RG32UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG32UI);
pub const SG_PIXELFORMAT_RG32SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG32SI);
pub const SG_PIXELFORMAT_RG32F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RG32F);
pub const SG_PIXELFORMAT_RGBA16 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA16);
pub const SG_PIXELFORMAT_RGBA16SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA16SN);
pub const SG_PIXELFORMAT_RGBA16UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA16UI);
pub const SG_PIXELFORMAT_RGBA16SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA16SI);
pub const SG_PIXELFORMAT_RGBA16F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA16F);
pub const SG_PIXELFORMAT_RGBA32UI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA32UI);
pub const SG_PIXELFORMAT_RGBA32SI = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA32SI);
pub const SG_PIXELFORMAT_RGBA32F = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_RGBA32F);
pub const SG_PIXELFORMAT_DEPTH = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_DEPTH);
pub const SG_PIXELFORMAT_DEPTH_STENCIL = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_DEPTH_STENCIL);
pub const SG_PIXELFORMAT_BC1_RGBA = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC1_RGBA);
pub const SG_PIXELFORMAT_BC2_RGBA = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC2_RGBA);
pub const SG_PIXELFORMAT_BC3_RGBA = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC3_RGBA);
pub const SG_PIXELFORMAT_BC4_R = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC4_R);
pub const SG_PIXELFORMAT_BC4_RSN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC4_RSN);
pub const SG_PIXELFORMAT_BC5_RG = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC5_RG);
pub const SG_PIXELFORMAT_BC5_RGSN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC5_RGSN);
pub const SG_PIXELFORMAT_BC6H_RGBF = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC6H_RGBF);
pub const SG_PIXELFORMAT_BC6H_RGBUF = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC6H_RGBUF);
pub const SG_PIXELFORMAT_BC7_RGBA = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_BC7_RGBA);
pub const SG_PIXELFORMAT_PVRTC_RGB_2BPP = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGB_2BPP);
pub const SG_PIXELFORMAT_PVRTC_RGB_4BPP = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGB_4BPP);
pub const SG_PIXELFORMAT_PVRTC_RGBA_2BPP = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGBA_2BPP);
pub const SG_PIXELFORMAT_PVRTC_RGBA_4BPP = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGBA_4BPP);
pub const SG_PIXELFORMAT_ETC2_RGB8 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_ETC2_RGB8);
pub const SG_PIXELFORMAT_ETC2_RGB8A1 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_ETC2_RGB8A1);
pub const SG_PIXELFORMAT_ETC2_RGBA8 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_ETC2_RGBA8);
pub const SG_PIXELFORMAT_ETC2_RG11 = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_ETC2_RG11);
pub const SG_PIXELFORMAT_ETC2_RG11SN = @enumToInt(enum_sg_pixel_format.SG_PIXELFORMAT_ETC2_RG11SN);
pub const _SG_PIXELFORMAT_NUM = @enumToInt(enum_sg_pixel_format._SG_PIXELFORMAT_NUM);
pub const _SG_PIXELFORMAT_FORCE_U32 = @enumToInt(enum_sg_pixel_format._SG_PIXELFORMAT_FORCE_U32);
pub const enum_sg_pixel_format = enum(c_int) {
    _SG_PIXELFORMAT_DEFAULT = 0,
    SG_PIXELFORMAT_NONE = 1,
    SG_PIXELFORMAT_R8 = 2,
    SG_PIXELFORMAT_R8SN = 3,
    SG_PIXELFORMAT_R8UI = 4,
    SG_PIXELFORMAT_R8SI = 5,
    SG_PIXELFORMAT_R16 = 6,
    SG_PIXELFORMAT_R16SN = 7,
    SG_PIXELFORMAT_R16UI = 8,
    SG_PIXELFORMAT_R16SI = 9,
    SG_PIXELFORMAT_R16F = 10,
    SG_PIXELFORMAT_RG8 = 11,
    SG_PIXELFORMAT_RG8SN = 12,
    SG_PIXELFORMAT_RG8UI = 13,
    SG_PIXELFORMAT_RG8SI = 14,
    SG_PIXELFORMAT_R32UI = 15,
    SG_PIXELFORMAT_R32SI = 16,
    SG_PIXELFORMAT_R32F = 17,
    SG_PIXELFORMAT_RG16 = 18,
    SG_PIXELFORMAT_RG16SN = 19,
    SG_PIXELFORMAT_RG16UI = 20,
    SG_PIXELFORMAT_RG16SI = 21,
    SG_PIXELFORMAT_RG16F = 22,
    SG_PIXELFORMAT_RGBA8 = 23,
    SG_PIXELFORMAT_RGBA8SN = 24,
    SG_PIXELFORMAT_RGBA8UI = 25,
    SG_PIXELFORMAT_RGBA8SI = 26,
    SG_PIXELFORMAT_BGRA8 = 27,
    SG_PIXELFORMAT_RGB10A2 = 28,
    SG_PIXELFORMAT_RG11B10F = 29,
    SG_PIXELFORMAT_RG32UI = 30,
    SG_PIXELFORMAT_RG32SI = 31,
    SG_PIXELFORMAT_RG32F = 32,
    SG_PIXELFORMAT_RGBA16 = 33,
    SG_PIXELFORMAT_RGBA16SN = 34,
    SG_PIXELFORMAT_RGBA16UI = 35,
    SG_PIXELFORMAT_RGBA16SI = 36,
    SG_PIXELFORMAT_RGBA16F = 37,
    SG_PIXELFORMAT_RGBA32UI = 38,
    SG_PIXELFORMAT_RGBA32SI = 39,
    SG_PIXELFORMAT_RGBA32F = 40,
    SG_PIXELFORMAT_DEPTH = 41,
    SG_PIXELFORMAT_DEPTH_STENCIL = 42,
    SG_PIXELFORMAT_BC1_RGBA = 43,
    SG_PIXELFORMAT_BC2_RGBA = 44,
    SG_PIXELFORMAT_BC3_RGBA = 45,
    SG_PIXELFORMAT_BC4_R = 46,
    SG_PIXELFORMAT_BC4_RSN = 47,
    SG_PIXELFORMAT_BC5_RG = 48,
    SG_PIXELFORMAT_BC5_RGSN = 49,
    SG_PIXELFORMAT_BC6H_RGBF = 50,
    SG_PIXELFORMAT_BC6H_RGBUF = 51,
    SG_PIXELFORMAT_BC7_RGBA = 52,
    SG_PIXELFORMAT_PVRTC_RGB_2BPP = 53,
    SG_PIXELFORMAT_PVRTC_RGB_4BPP = 54,
    SG_PIXELFORMAT_PVRTC_RGBA_2BPP = 55,
    SG_PIXELFORMAT_PVRTC_RGBA_4BPP = 56,
    SG_PIXELFORMAT_ETC2_RGB8 = 57,
    SG_PIXELFORMAT_ETC2_RGB8A1 = 58,
    SG_PIXELFORMAT_ETC2_RGBA8 = 59,
    SG_PIXELFORMAT_ETC2_RG11 = 60,
    SG_PIXELFORMAT_ETC2_RG11SN = 61,
    _SG_PIXELFORMAT_NUM = 62,
    _SG_PIXELFORMAT_FORCE_U32 = 2147483647,
    _,
};
pub const sg_pixel_format = enum_sg_pixel_format;
pub const struct_sg_pixelformat_info = extern struct {
    sample: bool,
    filter: bool,
    render: bool,
    blend: bool,
    msaa: bool,
    depth: bool,
};
pub const sg_pixelformat_info = struct_sg_pixelformat_info;
pub const struct_sg_features = extern struct {
    instancing: bool,
    origin_top_left: bool,
    multiple_render_targets: bool,
    msaa_render_targets: bool,
    imagetype_3d: bool,
    imagetype_array: bool,
    image_clamp_to_border: bool,
};
pub const sg_features = struct_sg_features;
pub const struct_sg_limits = extern struct {
    max_image_size_2d: u32,
    max_image_size_cube: u32,
    max_image_size_3d: u32,
    max_image_size_array: u32,
    max_image_array_layers: u32,
    max_vertex_attrs: u32,
};
pub const sg_limits = struct_sg_limits;
pub const SG_RESOURCESTATE_INITIAL = @enumToInt(enum_sg_resource_state.SG_RESOURCESTATE_INITIAL);
pub const SG_RESOURCESTATE_ALLOC = @enumToInt(enum_sg_resource_state.SG_RESOURCESTATE_ALLOC);
pub const SG_RESOURCESTATE_VALID = @enumToInt(enum_sg_resource_state.SG_RESOURCESTATE_VALID);
pub const SG_RESOURCESTATE_FAILED = @enumToInt(enum_sg_resource_state.SG_RESOURCESTATE_FAILED);
pub const SG_RESOURCESTATE_INVALID = @enumToInt(enum_sg_resource_state.SG_RESOURCESTATE_INVALID);
pub const _SG_RESOURCESTATE_FORCE_U32 = @enumToInt(enum_sg_resource_state._SG_RESOURCESTATE_FORCE_U32);
pub const enum_sg_resource_state = enum(c_int) {
    SG_RESOURCESTATE_INITIAL = 0,
    SG_RESOURCESTATE_ALLOC = 1,
    SG_RESOURCESTATE_VALID = 2,
    SG_RESOURCESTATE_FAILED = 3,
    SG_RESOURCESTATE_INVALID = 4,
    _SG_RESOURCESTATE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_resource_state = enum_sg_resource_state;
pub const _SG_USAGE_DEFAULT = @enumToInt(enum_sg_usage._SG_USAGE_DEFAULT);
pub const SG_USAGE_IMMUTABLE = @enumToInt(enum_sg_usage.SG_USAGE_IMMUTABLE);
pub const SG_USAGE_DYNAMIC = @enumToInt(enum_sg_usage.SG_USAGE_DYNAMIC);
pub const SG_USAGE_STREAM = @enumToInt(enum_sg_usage.SG_USAGE_STREAM);
pub const _SG_USAGE_NUM = @enumToInt(enum_sg_usage._SG_USAGE_NUM);
pub const _SG_USAGE_FORCE_U32 = @enumToInt(enum_sg_usage._SG_USAGE_FORCE_U32);
pub const enum_sg_usage = enum(c_int) {
    _SG_USAGE_DEFAULT = 0,
    SG_USAGE_IMMUTABLE = 1,
    SG_USAGE_DYNAMIC = 2,
    SG_USAGE_STREAM = 3,
    _SG_USAGE_NUM = 4,
    _SG_USAGE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_usage = enum_sg_usage;
pub const _SG_BUFFERTYPE_DEFAULT = @enumToInt(enum_sg_buffer_type._SG_BUFFERTYPE_DEFAULT);
pub const SG_BUFFERTYPE_VERTEXBUFFER = @enumToInt(enum_sg_buffer_type.SG_BUFFERTYPE_VERTEXBUFFER);
pub const SG_BUFFERTYPE_INDEXBUFFER = @enumToInt(enum_sg_buffer_type.SG_BUFFERTYPE_INDEXBUFFER);
pub const _SG_BUFFERTYPE_NUM = @enumToInt(enum_sg_buffer_type._SG_BUFFERTYPE_NUM);
pub const _SG_BUFFERTYPE_FORCE_U32 = @enumToInt(enum_sg_buffer_type._SG_BUFFERTYPE_FORCE_U32);
pub const enum_sg_buffer_type = enum(c_int) {
    _SG_BUFFERTYPE_DEFAULT = 0,
    SG_BUFFERTYPE_VERTEXBUFFER = 1,
    SG_BUFFERTYPE_INDEXBUFFER = 2,
    _SG_BUFFERTYPE_NUM = 3,
    _SG_BUFFERTYPE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_buffer_type = enum_sg_buffer_type;
pub const _SG_INDEXTYPE_DEFAULT = @enumToInt(enum_sg_index_type._SG_INDEXTYPE_DEFAULT);
pub const SG_INDEXTYPE_NONE = @enumToInt(enum_sg_index_type.SG_INDEXTYPE_NONE);
pub const SG_INDEXTYPE_UINT16 = @enumToInt(enum_sg_index_type.SG_INDEXTYPE_UINT16);
pub const SG_INDEXTYPE_UINT32 = @enumToInt(enum_sg_index_type.SG_INDEXTYPE_UINT32);
pub const _SG_INDEXTYPE_NUM = @enumToInt(enum_sg_index_type._SG_INDEXTYPE_NUM);
pub const _SG_INDEXTYPE_FORCE_U32 = @enumToInt(enum_sg_index_type._SG_INDEXTYPE_FORCE_U32);
pub const enum_sg_index_type = enum(c_int) {
    _SG_INDEXTYPE_DEFAULT = 0,
    SG_INDEXTYPE_NONE = 1,
    SG_INDEXTYPE_UINT16 = 2,
    SG_INDEXTYPE_UINT32 = 3,
    _SG_INDEXTYPE_NUM = 4,
    _SG_INDEXTYPE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_index_type = enum_sg_index_type;
pub const _SG_IMAGETYPE_DEFAULT = @enumToInt(enum_sg_image_type._SG_IMAGETYPE_DEFAULT);
pub const SG_IMAGETYPE_2D = @enumToInt(enum_sg_image_type.SG_IMAGETYPE_2D);
pub const SG_IMAGETYPE_CUBE = @enumToInt(enum_sg_image_type.SG_IMAGETYPE_CUBE);
pub const SG_IMAGETYPE_3D = @enumToInt(enum_sg_image_type.SG_IMAGETYPE_3D);
pub const SG_IMAGETYPE_ARRAY = @enumToInt(enum_sg_image_type.SG_IMAGETYPE_ARRAY);
pub const _SG_IMAGETYPE_NUM = @enumToInt(enum_sg_image_type._SG_IMAGETYPE_NUM);
pub const _SG_IMAGETYPE_FORCE_U32 = @enumToInt(enum_sg_image_type._SG_IMAGETYPE_FORCE_U32);
pub const enum_sg_image_type = enum(c_int) {
    _SG_IMAGETYPE_DEFAULT = 0,
    SG_IMAGETYPE_2D = 1,
    SG_IMAGETYPE_CUBE = 2,
    SG_IMAGETYPE_3D = 3,
    SG_IMAGETYPE_ARRAY = 4,
    _SG_IMAGETYPE_NUM = 5,
    _SG_IMAGETYPE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_image_type = enum_sg_image_type;
pub const _SG_SAMPLERTYPE_DEFAULT = @enumToInt(enum_sg_sampler_type._SG_SAMPLERTYPE_DEFAULT);
pub const SG_SAMPLERTYPE_FLOAT = @enumToInt(enum_sg_sampler_type.SG_SAMPLERTYPE_FLOAT);
pub const SG_SAMPLERTYPE_SINT = @enumToInt(enum_sg_sampler_type.SG_SAMPLERTYPE_SINT);
pub const SG_SAMPLERTYPE_UINT = @enumToInt(enum_sg_sampler_type.SG_SAMPLERTYPE_UINT);
pub const enum_sg_sampler_type = enum(c_int) {
    _SG_SAMPLERTYPE_DEFAULT,
    SG_SAMPLERTYPE_FLOAT,
    SG_SAMPLERTYPE_SINT,
    SG_SAMPLERTYPE_UINT,
    _,
};
pub const sg_sampler_type = enum_sg_sampler_type;
pub const SG_CUBEFACE_POS_X = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_POS_X);
pub const SG_CUBEFACE_NEG_X = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_NEG_X);
pub const SG_CUBEFACE_POS_Y = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_POS_Y);
pub const SG_CUBEFACE_NEG_Y = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_NEG_Y);
pub const SG_CUBEFACE_POS_Z = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_POS_Z);
pub const SG_CUBEFACE_NEG_Z = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_NEG_Z);
pub const SG_CUBEFACE_NUM = @enumToInt(enum_sg_cube_face.SG_CUBEFACE_NUM);
pub const _SG_CUBEFACE_FORCE_U32 = @enumToInt(enum_sg_cube_face._SG_CUBEFACE_FORCE_U32);
pub const enum_sg_cube_face = enum(c_int) {
    SG_CUBEFACE_POS_X = 0,
    SG_CUBEFACE_NEG_X = 1,
    SG_CUBEFACE_POS_Y = 2,
    SG_CUBEFACE_NEG_Y = 3,
    SG_CUBEFACE_POS_Z = 4,
    SG_CUBEFACE_NEG_Z = 5,
    SG_CUBEFACE_NUM = 6,
    _SG_CUBEFACE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_cube_face = enum_sg_cube_face;
pub const SG_SHADERSTAGE_VS = @enumToInt(enum_sg_shader_stage.SG_SHADERSTAGE_VS);
pub const SG_SHADERSTAGE_FS = @enumToInt(enum_sg_shader_stage.SG_SHADERSTAGE_FS);
pub const _SG_SHADERSTAGE_FORCE_U32 = @enumToInt(enum_sg_shader_stage._SG_SHADERSTAGE_FORCE_U32);
pub const enum_sg_shader_stage = enum(c_int) {
    SG_SHADERSTAGE_VS = 0,
    SG_SHADERSTAGE_FS = 1,
    _SG_SHADERSTAGE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_shader_stage = enum_sg_shader_stage;
pub const _SG_PRIMITIVETYPE_DEFAULT = @enumToInt(enum_sg_primitive_type._SG_PRIMITIVETYPE_DEFAULT);
pub const SG_PRIMITIVETYPE_POINTS = @enumToInt(enum_sg_primitive_type.SG_PRIMITIVETYPE_POINTS);
pub const SG_PRIMITIVETYPE_LINES = @enumToInt(enum_sg_primitive_type.SG_PRIMITIVETYPE_LINES);
pub const SG_PRIMITIVETYPE_LINE_STRIP = @enumToInt(enum_sg_primitive_type.SG_PRIMITIVETYPE_LINE_STRIP);
pub const SG_PRIMITIVETYPE_TRIANGLES = @enumToInt(enum_sg_primitive_type.SG_PRIMITIVETYPE_TRIANGLES);
pub const SG_PRIMITIVETYPE_TRIANGLE_STRIP = @enumToInt(enum_sg_primitive_type.SG_PRIMITIVETYPE_TRIANGLE_STRIP);
pub const _SG_PRIMITIVETYPE_NUM = @enumToInt(enum_sg_primitive_type._SG_PRIMITIVETYPE_NUM);
pub const _SG_PRIMITIVETYPE_FORCE_U32 = @enumToInt(enum_sg_primitive_type._SG_PRIMITIVETYPE_FORCE_U32);
pub const enum_sg_primitive_type = enum(c_int) {
    _SG_PRIMITIVETYPE_DEFAULT = 0,
    SG_PRIMITIVETYPE_POINTS = 1,
    SG_PRIMITIVETYPE_LINES = 2,
    SG_PRIMITIVETYPE_LINE_STRIP = 3,
    SG_PRIMITIVETYPE_TRIANGLES = 4,
    SG_PRIMITIVETYPE_TRIANGLE_STRIP = 5,
    _SG_PRIMITIVETYPE_NUM = 6,
    _SG_PRIMITIVETYPE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_primitive_type = enum_sg_primitive_type;
pub const _SG_FILTER_DEFAULT = @enumToInt(enum_sg_filter._SG_FILTER_DEFAULT);
pub const SG_FILTER_NEAREST = @enumToInt(enum_sg_filter.SG_FILTER_NEAREST);
pub const SG_FILTER_LINEAR = @enumToInt(enum_sg_filter.SG_FILTER_LINEAR);
pub const SG_FILTER_NEAREST_MIPMAP_NEAREST = @enumToInt(enum_sg_filter.SG_FILTER_NEAREST_MIPMAP_NEAREST);
pub const SG_FILTER_NEAREST_MIPMAP_LINEAR = @enumToInt(enum_sg_filter.SG_FILTER_NEAREST_MIPMAP_LINEAR);
pub const SG_FILTER_LINEAR_MIPMAP_NEAREST = @enumToInt(enum_sg_filter.SG_FILTER_LINEAR_MIPMAP_NEAREST);
pub const SG_FILTER_LINEAR_MIPMAP_LINEAR = @enumToInt(enum_sg_filter.SG_FILTER_LINEAR_MIPMAP_LINEAR);
pub const _SG_FILTER_NUM = @enumToInt(enum_sg_filter._SG_FILTER_NUM);
pub const _SG_FILTER_FORCE_U32 = @enumToInt(enum_sg_filter._SG_FILTER_FORCE_U32);
pub const enum_sg_filter = enum(c_int) {
    _SG_FILTER_DEFAULT = 0,
    SG_FILTER_NEAREST = 1,
    SG_FILTER_LINEAR = 2,
    SG_FILTER_NEAREST_MIPMAP_NEAREST = 3,
    SG_FILTER_NEAREST_MIPMAP_LINEAR = 4,
    SG_FILTER_LINEAR_MIPMAP_NEAREST = 5,
    SG_FILTER_LINEAR_MIPMAP_LINEAR = 6,
    _SG_FILTER_NUM = 7,
    _SG_FILTER_FORCE_U32 = 2147483647,
    _,
};
pub const sg_filter = enum_sg_filter;
pub const _SG_WRAP_DEFAULT = @enumToInt(enum_sg_wrap._SG_WRAP_DEFAULT);
pub const SG_WRAP_REPEAT = @enumToInt(enum_sg_wrap.SG_WRAP_REPEAT);
pub const SG_WRAP_CLAMP_TO_EDGE = @enumToInt(enum_sg_wrap.SG_WRAP_CLAMP_TO_EDGE);
pub const SG_WRAP_CLAMP_TO_BORDER = @enumToInt(enum_sg_wrap.SG_WRAP_CLAMP_TO_BORDER);
pub const SG_WRAP_MIRRORED_REPEAT = @enumToInt(enum_sg_wrap.SG_WRAP_MIRRORED_REPEAT);
pub const _SG_WRAP_NUM = @enumToInt(enum_sg_wrap._SG_WRAP_NUM);
pub const _SG_WRAP_FORCE_U32 = @enumToInt(enum_sg_wrap._SG_WRAP_FORCE_U32);
pub const enum_sg_wrap = enum(c_int) {
    _SG_WRAP_DEFAULT = 0,
    SG_WRAP_REPEAT = 1,
    SG_WRAP_CLAMP_TO_EDGE = 2,
    SG_WRAP_CLAMP_TO_BORDER = 3,
    SG_WRAP_MIRRORED_REPEAT = 4,
    _SG_WRAP_NUM = 5,
    _SG_WRAP_FORCE_U32 = 2147483647,
    _,
};
pub const sg_wrap = enum_sg_wrap;
pub const _SG_BORDERCOLOR_DEFAULT = @enumToInt(enum_sg_border_color._SG_BORDERCOLOR_DEFAULT);
pub const SG_BORDERCOLOR_TRANSPARENT_BLACK = @enumToInt(enum_sg_border_color.SG_BORDERCOLOR_TRANSPARENT_BLACK);
pub const SG_BORDERCOLOR_OPAQUE_BLACK = @enumToInt(enum_sg_border_color.SG_BORDERCOLOR_OPAQUE_BLACK);
pub const SG_BORDERCOLOR_OPAQUE_WHITE = @enumToInt(enum_sg_border_color.SG_BORDERCOLOR_OPAQUE_WHITE);
pub const _SG_BORDERCOLOR_NUM = @enumToInt(enum_sg_border_color._SG_BORDERCOLOR_NUM);
pub const _SG_BORDERCOLOR_FORCE_U32 = @enumToInt(enum_sg_border_color._SG_BORDERCOLOR_FORCE_U32);
pub const enum_sg_border_color = enum(c_int) {
    _SG_BORDERCOLOR_DEFAULT = 0,
    SG_BORDERCOLOR_TRANSPARENT_BLACK = 1,
    SG_BORDERCOLOR_OPAQUE_BLACK = 2,
    SG_BORDERCOLOR_OPAQUE_WHITE = 3,
    _SG_BORDERCOLOR_NUM = 4,
    _SG_BORDERCOLOR_FORCE_U32 = 2147483647,
    _,
};
pub const sg_border_color = enum_sg_border_color;
pub const SG_VERTEXFORMAT_INVALID = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_INVALID);
pub const SG_VERTEXFORMAT_FLOAT = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_FLOAT);
pub const SG_VERTEXFORMAT_FLOAT2 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_FLOAT2);
pub const SG_VERTEXFORMAT_FLOAT3 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_FLOAT3);
pub const SG_VERTEXFORMAT_FLOAT4 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_FLOAT4);
pub const SG_VERTEXFORMAT_BYTE4 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_BYTE4);
pub const SG_VERTEXFORMAT_BYTE4N = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_BYTE4N);
pub const SG_VERTEXFORMAT_UBYTE4 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_UBYTE4);
pub const SG_VERTEXFORMAT_UBYTE4N = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_UBYTE4N);
pub const SG_VERTEXFORMAT_SHORT2 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_SHORT2);
pub const SG_VERTEXFORMAT_SHORT2N = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_SHORT2N);
pub const SG_VERTEXFORMAT_USHORT2N = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_USHORT2N);
pub const SG_VERTEXFORMAT_SHORT4 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_SHORT4);
pub const SG_VERTEXFORMAT_SHORT4N = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_SHORT4N);
pub const SG_VERTEXFORMAT_USHORT4N = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_USHORT4N);
pub const SG_VERTEXFORMAT_UINT10_N2 = @enumToInt(enum_sg_vertex_format.SG_VERTEXFORMAT_UINT10_N2);
pub const _SG_VERTEXFORMAT_NUM = @enumToInt(enum_sg_vertex_format._SG_VERTEXFORMAT_NUM);
pub const _SG_VERTEXFORMAT_FORCE_U32 = @enumToInt(enum_sg_vertex_format._SG_VERTEXFORMAT_FORCE_U32);
pub const enum_sg_vertex_format = enum(c_int) {
    SG_VERTEXFORMAT_INVALID = 0,
    SG_VERTEXFORMAT_FLOAT = 1,
    SG_VERTEXFORMAT_FLOAT2 = 2,
    SG_VERTEXFORMAT_FLOAT3 = 3,
    SG_VERTEXFORMAT_FLOAT4 = 4,
    SG_VERTEXFORMAT_BYTE4 = 5,
    SG_VERTEXFORMAT_BYTE4N = 6,
    SG_VERTEXFORMAT_UBYTE4 = 7,
    SG_VERTEXFORMAT_UBYTE4N = 8,
    SG_VERTEXFORMAT_SHORT2 = 9,
    SG_VERTEXFORMAT_SHORT2N = 10,
    SG_VERTEXFORMAT_USHORT2N = 11,
    SG_VERTEXFORMAT_SHORT4 = 12,
    SG_VERTEXFORMAT_SHORT4N = 13,
    SG_VERTEXFORMAT_USHORT4N = 14,
    SG_VERTEXFORMAT_UINT10_N2 = 15,
    _SG_VERTEXFORMAT_NUM = 16,
    _SG_VERTEXFORMAT_FORCE_U32 = 2147483647,
    _,
};
pub const sg_vertex_format = enum_sg_vertex_format;
pub const _SG_VERTEXSTEP_DEFAULT = @enumToInt(enum_sg_vertex_step._SG_VERTEXSTEP_DEFAULT);
pub const SG_VERTEXSTEP_PER_VERTEX = @enumToInt(enum_sg_vertex_step.SG_VERTEXSTEP_PER_VERTEX);
pub const SG_VERTEXSTEP_PER_INSTANCE = @enumToInt(enum_sg_vertex_step.SG_VERTEXSTEP_PER_INSTANCE);
pub const _SG_VERTEXSTEP_NUM = @enumToInt(enum_sg_vertex_step._SG_VERTEXSTEP_NUM);
pub const _SG_VERTEXSTEP_FORCE_U32 = @enumToInt(enum_sg_vertex_step._SG_VERTEXSTEP_FORCE_U32);
pub const enum_sg_vertex_step = enum(c_int) {
    _SG_VERTEXSTEP_DEFAULT = 0,
    SG_VERTEXSTEP_PER_VERTEX = 1,
    SG_VERTEXSTEP_PER_INSTANCE = 2,
    _SG_VERTEXSTEP_NUM = 3,
    _SG_VERTEXSTEP_FORCE_U32 = 2147483647,
    _,
};
pub const sg_vertex_step = enum_sg_vertex_step;
pub const SG_UNIFORMTYPE_INVALID = @enumToInt(enum_sg_uniform_type.SG_UNIFORMTYPE_INVALID);
pub const SG_UNIFORMTYPE_FLOAT = @enumToInt(enum_sg_uniform_type.SG_UNIFORMTYPE_FLOAT);
pub const SG_UNIFORMTYPE_FLOAT2 = @enumToInt(enum_sg_uniform_type.SG_UNIFORMTYPE_FLOAT2);
pub const SG_UNIFORMTYPE_FLOAT3 = @enumToInt(enum_sg_uniform_type.SG_UNIFORMTYPE_FLOAT3);
pub const SG_UNIFORMTYPE_FLOAT4 = @enumToInt(enum_sg_uniform_type.SG_UNIFORMTYPE_FLOAT4);
pub const SG_UNIFORMTYPE_MAT4 = @enumToInt(enum_sg_uniform_type.SG_UNIFORMTYPE_MAT4);
pub const _SG_UNIFORMTYPE_NUM = @enumToInt(enum_sg_uniform_type._SG_UNIFORMTYPE_NUM);
pub const _SG_UNIFORMTYPE_FORCE_U32 = @enumToInt(enum_sg_uniform_type._SG_UNIFORMTYPE_FORCE_U32);
pub const enum_sg_uniform_type = enum(c_int) {
    SG_UNIFORMTYPE_INVALID = 0,
    SG_UNIFORMTYPE_FLOAT = 1,
    SG_UNIFORMTYPE_FLOAT2 = 2,
    SG_UNIFORMTYPE_FLOAT3 = 3,
    SG_UNIFORMTYPE_FLOAT4 = 4,
    SG_UNIFORMTYPE_MAT4 = 5,
    _SG_UNIFORMTYPE_NUM = 6,
    _SG_UNIFORMTYPE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_uniform_type = enum_sg_uniform_type;
pub const _SG_CULLMODE_DEFAULT = @enumToInt(enum_sg_cull_mode._SG_CULLMODE_DEFAULT);
pub const SG_CULLMODE_NONE = @enumToInt(enum_sg_cull_mode.SG_CULLMODE_NONE);
pub const SG_CULLMODE_FRONT = @enumToInt(enum_sg_cull_mode.SG_CULLMODE_FRONT);
pub const SG_CULLMODE_BACK = @enumToInt(enum_sg_cull_mode.SG_CULLMODE_BACK);
pub const _SG_CULLMODE_NUM = @enumToInt(enum_sg_cull_mode._SG_CULLMODE_NUM);
pub const _SG_CULLMODE_FORCE_U32 = @enumToInt(enum_sg_cull_mode._SG_CULLMODE_FORCE_U32);
pub const enum_sg_cull_mode = enum(c_int) {
    _SG_CULLMODE_DEFAULT = 0,
    SG_CULLMODE_NONE = 1,
    SG_CULLMODE_FRONT = 2,
    SG_CULLMODE_BACK = 3,
    _SG_CULLMODE_NUM = 4,
    _SG_CULLMODE_FORCE_U32 = 2147483647,
    _,
};
pub const sg_cull_mode = enum_sg_cull_mode;
pub const _SG_FACEWINDING_DEFAULT = @enumToInt(enum_sg_face_winding._SG_FACEWINDING_DEFAULT);
pub const SG_FACEWINDING_CCW = @enumToInt(enum_sg_face_winding.SG_FACEWINDING_CCW);
pub const SG_FACEWINDING_CW = @enumToInt(enum_sg_face_winding.SG_FACEWINDING_CW);
pub const _SG_FACEWINDING_NUM = @enumToInt(enum_sg_face_winding._SG_FACEWINDING_NUM);
pub const _SG_FACEWINDING_FORCE_U32 = @enumToInt(enum_sg_face_winding._SG_FACEWINDING_FORCE_U32);
pub const enum_sg_face_winding = enum(c_int) {
    _SG_FACEWINDING_DEFAULT = 0,
    SG_FACEWINDING_CCW = 1,
    SG_FACEWINDING_CW = 2,
    _SG_FACEWINDING_NUM = 3,
    _SG_FACEWINDING_FORCE_U32 = 2147483647,
    _,
};
pub const sg_face_winding = enum_sg_face_winding;
pub const _SG_COMPAREFUNC_DEFAULT = @enumToInt(enum_sg_compare_func._SG_COMPAREFUNC_DEFAULT);
pub const SG_COMPAREFUNC_NEVER = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_NEVER);
pub const SG_COMPAREFUNC_LESS = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_LESS);
pub const SG_COMPAREFUNC_EQUAL = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_EQUAL);
pub const SG_COMPAREFUNC_LESS_EQUAL = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_LESS_EQUAL);
pub const SG_COMPAREFUNC_GREATER = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_GREATER);
pub const SG_COMPAREFUNC_NOT_EQUAL = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_NOT_EQUAL);
pub const SG_COMPAREFUNC_GREATER_EQUAL = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_GREATER_EQUAL);
pub const SG_COMPAREFUNC_ALWAYS = @enumToInt(enum_sg_compare_func.SG_COMPAREFUNC_ALWAYS);
pub const _SG_COMPAREFUNC_NUM = @enumToInt(enum_sg_compare_func._SG_COMPAREFUNC_NUM);
pub const _SG_COMPAREFUNC_FORCE_U32 = @enumToInt(enum_sg_compare_func._SG_COMPAREFUNC_FORCE_U32);
pub const enum_sg_compare_func = enum(c_int) {
    _SG_COMPAREFUNC_DEFAULT = 0,
    SG_COMPAREFUNC_NEVER = 1,
    SG_COMPAREFUNC_LESS = 2,
    SG_COMPAREFUNC_EQUAL = 3,
    SG_COMPAREFUNC_LESS_EQUAL = 4,
    SG_COMPAREFUNC_GREATER = 5,
    SG_COMPAREFUNC_NOT_EQUAL = 6,
    SG_COMPAREFUNC_GREATER_EQUAL = 7,
    SG_COMPAREFUNC_ALWAYS = 8,
    _SG_COMPAREFUNC_NUM = 9,
    _SG_COMPAREFUNC_FORCE_U32 = 2147483647,
    _,
};
pub const sg_compare_func = enum_sg_compare_func;
pub const _SG_STENCILOP_DEFAULT = @enumToInt(enum_sg_stencil_op._SG_STENCILOP_DEFAULT);
pub const SG_STENCILOP_KEEP = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_KEEP);
pub const SG_STENCILOP_ZERO = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_ZERO);
pub const SG_STENCILOP_REPLACE = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_REPLACE);
pub const SG_STENCILOP_INCR_CLAMP = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_INCR_CLAMP);
pub const SG_STENCILOP_DECR_CLAMP = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_DECR_CLAMP);
pub const SG_STENCILOP_INVERT = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_INVERT);
pub const SG_STENCILOP_INCR_WRAP = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_INCR_WRAP);
pub const SG_STENCILOP_DECR_WRAP = @enumToInt(enum_sg_stencil_op.SG_STENCILOP_DECR_WRAP);
pub const _SG_STENCILOP_NUM = @enumToInt(enum_sg_stencil_op._SG_STENCILOP_NUM);
pub const _SG_STENCILOP_FORCE_U32 = @enumToInt(enum_sg_stencil_op._SG_STENCILOP_FORCE_U32);
pub const enum_sg_stencil_op = enum(c_int) {
    _SG_STENCILOP_DEFAULT = 0,
    SG_STENCILOP_KEEP = 1,
    SG_STENCILOP_ZERO = 2,
    SG_STENCILOP_REPLACE = 3,
    SG_STENCILOP_INCR_CLAMP = 4,
    SG_STENCILOP_DECR_CLAMP = 5,
    SG_STENCILOP_INVERT = 6,
    SG_STENCILOP_INCR_WRAP = 7,
    SG_STENCILOP_DECR_WRAP = 8,
    _SG_STENCILOP_NUM = 9,
    _SG_STENCILOP_FORCE_U32 = 2147483647,
    _,
};
pub const sg_stencil_op = enum_sg_stencil_op;
pub const _SG_BLENDFACTOR_DEFAULT = @enumToInt(enum_sg_blend_factor._SG_BLENDFACTOR_DEFAULT);
pub const SG_BLENDFACTOR_ZERO = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ZERO);
pub const SG_BLENDFACTOR_ONE = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE);
pub const SG_BLENDFACTOR_SRC_COLOR = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_SRC_COLOR);
pub const SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR);
pub const SG_BLENDFACTOR_SRC_ALPHA = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_SRC_ALPHA);
pub const SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA);
pub const SG_BLENDFACTOR_DST_COLOR = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_DST_COLOR);
pub const SG_BLENDFACTOR_ONE_MINUS_DST_COLOR = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_DST_COLOR);
pub const SG_BLENDFACTOR_DST_ALPHA = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_DST_ALPHA);
pub const SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA);
pub const SG_BLENDFACTOR_SRC_ALPHA_SATURATED = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_SRC_ALPHA_SATURATED);
pub const SG_BLENDFACTOR_BLEND_COLOR = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_BLEND_COLOR);
pub const SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR);
pub const SG_BLENDFACTOR_BLEND_ALPHA = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_BLEND_ALPHA);
pub const SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA = @enumToInt(enum_sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA);
pub const _SG_BLENDFACTOR_NUM = @enumToInt(enum_sg_blend_factor._SG_BLENDFACTOR_NUM);
pub const _SG_BLENDFACTOR_FORCE_U32 = @enumToInt(enum_sg_blend_factor._SG_BLENDFACTOR_FORCE_U32);
pub const enum_sg_blend_factor = enum(c_int) {
    _SG_BLENDFACTOR_DEFAULT = 0,
    SG_BLENDFACTOR_ZERO = 1,
    SG_BLENDFACTOR_ONE = 2,
    SG_BLENDFACTOR_SRC_COLOR = 3,
    SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR = 4,
    SG_BLENDFACTOR_SRC_ALPHA = 5,
    SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = 6,
    SG_BLENDFACTOR_DST_COLOR = 7,
    SG_BLENDFACTOR_ONE_MINUS_DST_COLOR = 8,
    SG_BLENDFACTOR_DST_ALPHA = 9,
    SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA = 10,
    SG_BLENDFACTOR_SRC_ALPHA_SATURATED = 11,
    SG_BLENDFACTOR_BLEND_COLOR = 12,
    SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR = 13,
    SG_BLENDFACTOR_BLEND_ALPHA = 14,
    SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA = 15,
    _SG_BLENDFACTOR_NUM = 16,
    _SG_BLENDFACTOR_FORCE_U32 = 2147483647,
    _,
};
pub const sg_blend_factor = enum_sg_blend_factor;
pub const _SG_BLENDOP_DEFAULT = @enumToInt(enum_sg_blend_op._SG_BLENDOP_DEFAULT);
pub const SG_BLENDOP_ADD = @enumToInt(enum_sg_blend_op.SG_BLENDOP_ADD);
pub const SG_BLENDOP_SUBTRACT = @enumToInt(enum_sg_blend_op.SG_BLENDOP_SUBTRACT);
pub const SG_BLENDOP_REVERSE_SUBTRACT = @enumToInt(enum_sg_blend_op.SG_BLENDOP_REVERSE_SUBTRACT);
pub const _SG_BLENDOP_NUM = @enumToInt(enum_sg_blend_op._SG_BLENDOP_NUM);
pub const _SG_BLENDOP_FORCE_U32 = @enumToInt(enum_sg_blend_op._SG_BLENDOP_FORCE_U32);
pub const enum_sg_blend_op = enum(c_int) {
    _SG_BLENDOP_DEFAULT = 0,
    SG_BLENDOP_ADD = 1,
    SG_BLENDOP_SUBTRACT = 2,
    SG_BLENDOP_REVERSE_SUBTRACT = 3,
    _SG_BLENDOP_NUM = 4,
    _SG_BLENDOP_FORCE_U32 = 2147483647,
    _,
};
pub const sg_blend_op = enum_sg_blend_op;
pub const _SG_COLORMASK_DEFAULT = @enumToInt(enum_sg_color_mask._SG_COLORMASK_DEFAULT);
pub const SG_COLORMASK_NONE = @enumToInt(enum_sg_color_mask.SG_COLORMASK_NONE);
pub const SG_COLORMASK_R = @enumToInt(enum_sg_color_mask.SG_COLORMASK_R);
pub const SG_COLORMASK_G = @enumToInt(enum_sg_color_mask.SG_COLORMASK_G);
pub const SG_COLORMASK_B = @enumToInt(enum_sg_color_mask.SG_COLORMASK_B);
pub const SG_COLORMASK_A = @enumToInt(enum_sg_color_mask.SG_COLORMASK_A);
pub const SG_COLORMASK_RGB = @enumToInt(enum_sg_color_mask.SG_COLORMASK_RGB);
pub const SG_COLORMASK_RGBA = @enumToInt(enum_sg_color_mask.SG_COLORMASK_RGBA);
pub const _SG_COLORMASK_FORCE_U32 = @enumToInt(enum_sg_color_mask._SG_COLORMASK_FORCE_U32);
pub const enum_sg_color_mask = enum(c_int) {
    _SG_COLORMASK_DEFAULT = 0,
    SG_COLORMASK_NONE = 16,
    SG_COLORMASK_R = 1,
    SG_COLORMASK_G = 2,
    SG_COLORMASK_B = 4,
    SG_COLORMASK_A = 8,
    SG_COLORMASK_RGB = 7,
    SG_COLORMASK_RGBA = 15,
    _SG_COLORMASK_FORCE_U32 = 2147483647,
    _,
};
pub const sg_color_mask = enum_sg_color_mask;
pub const _SG_ACTION_DEFAULT = @enumToInt(enum_sg_action._SG_ACTION_DEFAULT);
pub const SG_ACTION_CLEAR = @enumToInt(enum_sg_action.SG_ACTION_CLEAR);
pub const SG_ACTION_LOAD = @enumToInt(enum_sg_action.SG_ACTION_LOAD);
pub const SG_ACTION_DONTCARE = @enumToInt(enum_sg_action.SG_ACTION_DONTCARE);
pub const _SG_ACTION_NUM = @enumToInt(enum_sg_action._SG_ACTION_NUM);
pub const _SG_ACTION_FORCE_U32 = @enumToInt(enum_sg_action._SG_ACTION_FORCE_U32);
pub const enum_sg_action = enum(c_int) {
    _SG_ACTION_DEFAULT = 0,
    SG_ACTION_CLEAR = 1,
    SG_ACTION_LOAD = 2,
    SG_ACTION_DONTCARE = 3,
    _SG_ACTION_NUM = 4,
    _SG_ACTION_FORCE_U32 = 2147483647,
    _,
};
pub const sg_action = enum_sg_action;
pub const struct_sg_color_attachment_action = extern struct {
    action: sg_action,
    val: [4]f32,
};
pub const sg_color_attachment_action = struct_sg_color_attachment_action;
pub const struct_sg_depth_attachment_action = extern struct {
    action: sg_action,
    val: f32,
};
pub const sg_depth_attachment_action = struct_sg_depth_attachment_action;
pub const struct_sg_stencil_attachment_action = extern struct {
    action: sg_action,
    val: u8,
};
pub const sg_stencil_attachment_action = struct_sg_stencil_attachment_action;
pub const struct_sg_pass_action = extern struct {
    _start_canary: u32,
    colors: [4]sg_color_attachment_action,
    depth: sg_depth_attachment_action,
    stencil: sg_stencil_attachment_action,
    _end_canary: u32,
};
pub const sg_pass_action = struct_sg_pass_action;
pub const struct_sg_bindings = extern struct {
    _start_canary: u32,
    vertex_buffers: [8]sg_buffer,
    vertex_buffer_offsets: [8]c_int,
    index_buffer: sg_buffer,
    index_buffer_offset: c_int,
    vs_images: [12]sg_image,
    fs_images: [12]sg_image,
    _end_canary: u32,
};
pub const sg_bindings = struct_sg_bindings;
pub const struct_sg_buffer_desc = extern struct {
    _start_canary: u32,
    size: c_int,
    type: sg_buffer_type,
    usage: sg_usage,
    content: ?*const anyopaque,
    label: [*c]const u8,
    gl_buffers: [2]u32,
    mtl_buffers: [2]?*const anyopaque,
    d3d11_buffer: ?*const anyopaque,
    wgpu_buffer: ?*const anyopaque,
    _end_canary: u32,
};
pub const sg_buffer_desc = struct_sg_buffer_desc;
pub const struct_sg_subimage_content = extern struct {
    ptr: ?*const anyopaque,
    size: c_int,
};
pub const sg_subimage_content = struct_sg_subimage_content;
pub const struct_sg_image_content = extern struct {
    subimage: [6][16]sg_subimage_content,
};
pub const sg_image_content = struct_sg_image_content;
const union_unnamed_3 = extern union {
    depth: c_int,
    layers: c_int,
};
pub const struct_sg_image_desc = extern struct {
    _start_canary: u32,
    type: sg_image_type,
    render_target: bool,
    width: c_int,
    height: c_int,
    unnamed_0: union_unnamed_3,
    num_mipmaps: c_int,
    usage: sg_usage,
    pixel_format: sg_pixel_format,
    sample_count: c_int,
    min_filter: sg_filter,
    mag_filter: sg_filter,
    wrap_u: sg_wrap,
    wrap_v: sg_wrap,
    wrap_w: sg_wrap,
    border_color: sg_border_color,
    max_anisotropy: u32,
    min_lod: f32,
    max_lod: f32,
    content: sg_image_content,
    label: [*c]const u8,
    gl_textures: [2]u32,
    mtl_textures: [2]?*const anyopaque,
    d3d11_texture: ?*const anyopaque,
    wgpu_texture: ?*const anyopaque,
    _end_canary: u32,
};
pub const sg_image_desc = struct_sg_image_desc;
pub const struct_sg_shader_attr_desc = extern struct {
    name: [*c]const u8,
    sem_name: [*c]const u8,
    sem_index: c_int,
};
pub const sg_shader_attr_desc = struct_sg_shader_attr_desc;
pub const struct_sg_shader_uniform_desc = extern struct {
    name: [*c]const u8,
    type: sg_uniform_type,
    array_count: c_int,
};
pub const sg_shader_uniform_desc = struct_sg_shader_uniform_desc;
pub const struct_sg_shader_uniform_block_desc = extern struct {
    size: c_int,
    uniforms: [16]sg_shader_uniform_desc,
};
pub const sg_shader_uniform_block_desc = struct_sg_shader_uniform_block_desc;
pub const struct_sg_shader_image_desc = extern struct {
    name: [*c]const u8,
    type: sg_image_type,
    sampler_type: sg_sampler_type,
};
pub const sg_shader_image_desc = struct_sg_shader_image_desc;
pub const struct_sg_shader_stage_desc = extern struct {
    source: [*c]const u8,
    byte_code: [*c]const u8,
    byte_code_size: c_int,
    entry: [*c]const u8,
    d3d11_target: [*c]const u8,
    uniform_blocks: [4]sg_shader_uniform_block_desc,
    images: [12]sg_shader_image_desc,
};
pub const sg_shader_stage_desc = struct_sg_shader_stage_desc;
pub const struct_sg_shader_desc = extern struct {
    _start_canary: u32,
    attrs: [16]sg_shader_attr_desc,
    vs: sg_shader_stage_desc,
    fs: sg_shader_stage_desc,
    label: [*c]const u8,
    _end_canary: u32,
};
pub const sg_shader_desc = struct_sg_shader_desc;
pub const struct_sg_buffer_layout_desc = extern struct {
    stride: c_int,
    step_func: sg_vertex_step,
    step_rate: c_int,
};
pub const sg_buffer_layout_desc = struct_sg_buffer_layout_desc;
pub const struct_sg_vertex_attr_desc = extern struct {
    buffer_index: c_int,
    offset: c_int,
    format: sg_vertex_format,
};
pub const sg_vertex_attr_desc = struct_sg_vertex_attr_desc;
pub const struct_sg_layout_desc = extern struct {
    buffers: [8]sg_buffer_layout_desc,
    attrs: [16]sg_vertex_attr_desc,
};
pub const sg_layout_desc = struct_sg_layout_desc;
pub const struct_sg_stencil_state = extern struct {
    fail_op: sg_stencil_op,
    depth_fail_op: sg_stencil_op,
    pass_op: sg_stencil_op,
    compare_func: sg_compare_func,
};
pub const sg_stencil_state = struct_sg_stencil_state;
pub const struct_sg_depth_stencil_state = extern struct {
    stencil_front: sg_stencil_state,
    stencil_back: sg_stencil_state,
    depth_compare_func: sg_compare_func,
    depth_write_enabled: bool,
    stencil_enabled: bool,
    stencil_read_mask: u8,
    stencil_write_mask: u8,
    stencil_ref: u8,
};
pub const sg_depth_stencil_state = struct_sg_depth_stencil_state;
pub const struct_sg_blend_state = extern struct {
    enabled: bool,
    src_factor_rgb: sg_blend_factor,
    dst_factor_rgb: sg_blend_factor,
    op_rgb: sg_blend_op,
    src_factor_alpha: sg_blend_factor,
    dst_factor_alpha: sg_blend_factor,
    op_alpha: sg_blend_op,
    color_write_mask: u8,
    color_attachment_count: c_int,
    color_format: sg_pixel_format,
    depth_format: sg_pixel_format,
    blend_color: [4]f32,
};
pub const sg_blend_state = struct_sg_blend_state;
pub const struct_sg_rasterizer_state = extern struct {
    alpha_to_coverage_enabled: bool,
    cull_mode: sg_cull_mode,
    face_winding: sg_face_winding,
    sample_count: c_int,
    depth_bias: f32,
    depth_bias_slope_scale: f32,
    depth_bias_clamp: f32,
};
pub const sg_rasterizer_state = struct_sg_rasterizer_state;
pub const struct_sg_pipeline_desc = extern struct {
    _start_canary: u32,
    layout: sg_layout_desc,
    shader: sg_shader,
    primitive_type: sg_primitive_type,
    index_type: sg_index_type,
    depth_stencil: sg_depth_stencil_state,
    blend: sg_blend_state,
    rasterizer: sg_rasterizer_state,
    label: [*c]const u8,
    _end_canary: u32,
};
pub const sg_pipeline_desc = struct_sg_pipeline_desc;
const union_unnamed_4 = extern union {
    face: c_int,
    layer: c_int,
    slice: c_int,
};
pub const struct_sg_attachment_desc = extern struct {
    image: sg_image,
    mip_level: c_int,
    unnamed_0: union_unnamed_4,
};
pub const sg_attachment_desc = struct_sg_attachment_desc;
pub const struct_sg_pass_desc = extern struct {
    _start_canary: u32,
    color_attachments: [4]sg_attachment_desc,
    depth_stencil_attachment: sg_attachment_desc,
    label: [*c]const u8,
    _end_canary: u32,
};
pub const sg_pass_desc = struct_sg_pass_desc;
pub const struct_sg_trace_hooks = extern struct {
    user_data: ?*anyopaque,
    reset_state_cache: ?fn (?*anyopaque) callconv(.C) void,
    make_buffer: ?fn ([*c]const sg_buffer_desc, sg_buffer, ?*anyopaque) callconv(.C) void,
    make_image: ?fn ([*c]const sg_image_desc, sg_image, ?*anyopaque) callconv(.C) void,
    make_shader: ?fn ([*c]const sg_shader_desc, sg_shader, ?*anyopaque) callconv(.C) void,
    make_pipeline: ?fn ([*c]const sg_pipeline_desc, sg_pipeline, ?*anyopaque) callconv(.C) void,
    make_pass: ?fn ([*c]const sg_pass_desc, sg_pass, ?*anyopaque) callconv(.C) void,
    destroy_buffer: ?fn (sg_buffer, ?*anyopaque) callconv(.C) void,
    destroy_image: ?fn (sg_image, ?*anyopaque) callconv(.C) void,
    destroy_shader: ?fn (sg_shader, ?*anyopaque) callconv(.C) void,
    destroy_pipeline: ?fn (sg_pipeline, ?*anyopaque) callconv(.C) void,
    destroy_pass: ?fn (sg_pass, ?*anyopaque) callconv(.C) void,
    update_buffer: ?fn (sg_buffer, ?*const anyopaque, c_int, ?*anyopaque) callconv(.C) void,
    update_image: ?fn (sg_image, [*c]const sg_image_content, ?*anyopaque) callconv(.C) void,
    append_buffer: ?fn (sg_buffer, ?*const anyopaque, c_int, c_int, ?*anyopaque) callconv(.C) void,
    begin_default_pass: ?fn ([*c]const sg_pass_action, c_int, c_int, ?*anyopaque) callconv(.C) void,
    begin_pass: ?fn (sg_pass, [*c]const sg_pass_action, ?*anyopaque) callconv(.C) void,
    apply_viewport: ?fn (c_int, c_int, c_int, c_int, bool, ?*anyopaque) callconv(.C) void,
    apply_scissor_rect: ?fn (c_int, c_int, c_int, c_int, bool, ?*anyopaque) callconv(.C) void,
    apply_pipeline: ?fn (sg_pipeline, ?*anyopaque) callconv(.C) void,
    apply_bindings: ?fn ([*c]const sg_bindings, ?*anyopaque) callconv(.C) void,
    apply_uniforms: ?fn (sg_shader_stage, c_int, ?*const anyopaque, c_int, ?*anyopaque) callconv(.C) void,
    draw: ?fn (c_int, c_int, c_int, ?*anyopaque) callconv(.C) void,
    end_pass: ?fn (?*anyopaque) callconv(.C) void,
    commit: ?fn (?*anyopaque) callconv(.C) void,
    alloc_buffer: ?fn (sg_buffer, ?*anyopaque) callconv(.C) void,
    alloc_image: ?fn (sg_image, ?*anyopaque) callconv(.C) void,
    alloc_shader: ?fn (sg_shader, ?*anyopaque) callconv(.C) void,
    alloc_pipeline: ?fn (sg_pipeline, ?*anyopaque) callconv(.C) void,
    alloc_pass: ?fn (sg_pass, ?*anyopaque) callconv(.C) void,
    init_buffer: ?fn (sg_buffer, [*c]const sg_buffer_desc, ?*anyopaque) callconv(.C) void,
    init_image: ?fn (sg_image, [*c]const sg_image_desc, ?*anyopaque) callconv(.C) void,
    init_shader: ?fn (sg_shader, [*c]const sg_shader_desc, ?*anyopaque) callconv(.C) void,
    init_pipeline: ?fn (sg_pipeline, [*c]const sg_pipeline_desc, ?*anyopaque) callconv(.C) void,
    init_pass: ?fn (sg_pass, [*c]const sg_pass_desc, ?*anyopaque) callconv(.C) void,
    fail_buffer: ?fn (sg_buffer, ?*anyopaque) callconv(.C) void,
    fail_image: ?fn (sg_image, ?*anyopaque) callconv(.C) void,
    fail_shader: ?fn (sg_shader, ?*anyopaque) callconv(.C) void,
    fail_pipeline: ?fn (sg_pipeline, ?*anyopaque) callconv(.C) void,
    fail_pass: ?fn (sg_pass, ?*anyopaque) callconv(.C) void,
    push_debug_group: ?fn ([*c]const u8, ?*anyopaque) callconv(.C) void,
    pop_debug_group: ?fn (?*anyopaque) callconv(.C) void,
    err_buffer_pool_exhausted: ?fn (?*anyopaque) callconv(.C) void,
    err_image_pool_exhausted: ?fn (?*anyopaque) callconv(.C) void,
    err_shader_pool_exhausted: ?fn (?*anyopaque) callconv(.C) void,
    err_pipeline_pool_exhausted: ?fn (?*anyopaque) callconv(.C) void,
    err_pass_pool_exhausted: ?fn (?*anyopaque) callconv(.C) void,
    err_context_mismatch: ?fn (?*anyopaque) callconv(.C) void,
    err_pass_invalid: ?fn (?*anyopaque) callconv(.C) void,
    err_draw_invalid: ?fn (?*anyopaque) callconv(.C) void,
    err_bindings_invalid: ?fn (?*anyopaque) callconv(.C) void,
};
pub const sg_trace_hooks = struct_sg_trace_hooks;
pub const struct_sg_slot_info = extern struct {
    state: sg_resource_state,
    res_id: u32,
    ctx_id: u32,
};
pub const sg_slot_info = struct_sg_slot_info;
pub const struct_sg_buffer_info = extern struct {
    slot: sg_slot_info,
    update_frame_index: u32,
    append_frame_index: u32,
    append_pos: c_int,
    append_overflow: bool,
    num_slots: c_int,
    active_slot: c_int,
};
pub const sg_buffer_info = struct_sg_buffer_info;
pub const struct_sg_image_info = extern struct {
    slot: sg_slot_info,
    upd_frame_index: u32,
    num_slots: c_int,
    active_slot: c_int,
    width: c_int,
    height: c_int,
};
pub const sg_image_info = struct_sg_image_info;
pub const struct_sg_shader_info = extern struct {
    slot: sg_slot_info,
};
pub const sg_shader_info = struct_sg_shader_info;
pub const struct_sg_pipeline_info = extern struct {
    slot: sg_slot_info,
};
pub const sg_pipeline_info = struct_sg_pipeline_info;
pub const struct_sg_pass_info = extern struct {
    slot: sg_slot_info,
};
pub const sg_pass_info = struct_sg_pass_info;
pub const struct_sg_gl_context_desc = extern struct {
    force_gles2: bool,
};
pub const sg_gl_context_desc = struct_sg_gl_context_desc;
pub const struct_sg_mtl_context_desc = extern struct {
    device: ?*const anyopaque,
    renderpass_descriptor_cb: ?fn () callconv(.C) ?*const anyopaque,
    drawable_cb: ?fn () callconv(.C) ?*const anyopaque,
};
pub const sg_metal_context_desc = struct_sg_mtl_context_desc;
pub const struct_sg_d3d11_context_desc = extern struct {
    device: ?*const anyopaque,
    device_context: ?*const anyopaque,
    render_target_view_cb: ?fn () callconv(.C) ?*const anyopaque,
    depth_stencil_view_cb: ?fn () callconv(.C) ?*const anyopaque,
};
pub const sg_d3d11_context_desc = struct_sg_d3d11_context_desc;
pub const struct_sg_wgpu_context_desc = extern struct {
    device: ?*const anyopaque,
    render_view_cb: ?fn () callconv(.C) ?*const anyopaque,
    resolve_view_cb: ?fn () callconv(.C) ?*const anyopaque,
    depth_stencil_view_cb: ?fn () callconv(.C) ?*const anyopaque,
};
pub const sg_wgpu_context_desc = struct_sg_wgpu_context_desc;
pub const struct_sg_context_desc = extern struct {
    color_format: sg_pixel_format,
    depth_format: sg_pixel_format,
    sample_count: c_int,
    gl: sg_gl_context_desc,
    metal: sg_metal_context_desc,
    d3d11: sg_d3d11_context_desc,
    wgpu: sg_wgpu_context_desc,
};
pub const sg_context_desc = struct_sg_context_desc;
pub const struct_sg_desc = extern struct {
    _start_canary: u32,
    buffer_pool_size: c_int,
    image_pool_size: c_int,
    shader_pool_size: c_int,
    pipeline_pool_size: c_int,
    pass_pool_size: c_int,
    context_pool_size: c_int,
    uniform_buffer_size: c_int,
    staging_buffer_size: c_int,
    sampler_cache_size: c_int,
    context: sg_context_desc,
    _end_canary: u32,
};
pub const sg_desc = struct_sg_desc;
