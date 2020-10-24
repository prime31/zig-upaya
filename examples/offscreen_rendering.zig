const std = @import("std");
const upaya = @import("upaya");
usingnamespace upaya.imgui;
usingnamespace upaya.sokol;
const Mat4 = upaya.math.Mat4;
const Vec3 = upaya.math.Vec3;

var state = struct {
    render_texture: upaya.RenderTexture = undefined,
    offscreen_pass: sg_pass = undefined,
    pass_action: sg_pass_action = undefined,
    pipeline: sg_pipeline = undefined,
    bindings: sg_bindings = undefined,
}{};

const VertShaderParams = struct {
    mvp: Mat4 = undefined
};

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {
    state.pass_action.colors[0].action = .SG_ACTION_CLEAR;
    state.pass_action.colors[0].val = [_]f32{ 0.2, 0.2, 0.2, 1.0 };

    state.render_texture = upaya.RenderTexture.init(380, 256, .linear);

    var pass_desc = std.mem.zeroes(sg_pass_desc);
    pass_desc.color_attachments[0].image = state.render_texture.img;
    state.offscreen_pass = sg_make_pass(&pass_desc);

    const vertices = [_]f32{
        // positions     // colors
        -1.0, -1.0, -1.0, 1.0, 0.0, 0.0, 1.0,
        1.0,  -1.0, -1.0, 1.0, 0.0, 0.0, 1.0,
        1.0,  1.0,  -1.0, 1.0, 0.0, 0.0, 1.0,
        -1.0, 1.0,  -1.0, 1.0, 0.0, 0.0, 1.0,

        -1.0, -1.0, 1.0,  0.0, 1.0, 0.0, 1.0,
        1.0,  -1.0, 1.0,  0.0, 1.0, 0.0, 1.0,
        1.0,  1.0,  1.0,  0.0, 1.0, 0.0, 1.0,
        -1.0, 1.0,  1.0,  0.0, 1.0, 0.0, 1.0,

        -1.0, -1.0, -1.0, 0.0, 0.0, 1.0, 1.0,
        -1.0, 1.0,  -1.0, 0.0, 0.0, 1.0, 1.0,
        -1.0, 1.0,  1.0,  0.0, 0.0, 1.0, 1.0,
        -1.0, -1.0, 1.0,  0.0, 0.0, 1.0, 1.0,

        1.0,  -1.0, -1.0, 1.0, 0.5, 0.0, 1.0,
        1.0,  1.0,  -1.0, 1.0, 0.5, 0.0, 1.0,
        1.0,  1.0,  1.0,  1.0, 0.5, 0.0, 1.0,
        1.0,  -1.0, 1.0,  1.0, 0.5, 0.0, 1.0,

        -1.0, -1.0, -1.0, 0.0, 0.5, 1.0, 1.0,
        -1.0, -1.0, 1.0,  0.0, 0.5, 1.0, 1.0,
        1.0,  -1.0, 1.0,  0.0, 0.5, 1.0, 1.0,
        1.0,  -1.0, -1.0, 0.0, 0.5, 1.0, 1.0,

        -1.0, 1.0,  -1.0, 1.0, 0.0, 0.5, 1.0,
        -1.0, 1.0,  1.0,  1.0, 0.0, 0.5, 1.0,
        1.0,  1.0,  1.0,  1.0, 0.0, 0.5, 1.0,
        1.0,  1.0,  -1.0, 1.0, 0.0, 0.5, 1.0,
    };

    const indices = [_]u16{
        0,  1,  2,  0,  2,  3,
        6,  5,  4,  7,  6,  4,
        8,  9,  10, 8,  10, 11,
        14, 13, 12, 15, 14, 12,
        16, 17, 18, 16, 18, 19,
        22, 21, 20, 23, 22, 20,
    };

    var buffer_desc = std.mem.zeroes(sg_buffer_desc);
    buffer_desc.size = vertices.len * @sizeOf(f32);
    buffer_desc.content = &vertices[0];
    state.bindings.vertex_buffers[0] = sg_make_buffer(&buffer_desc);

    buffer_desc = std.mem.zeroes(sg_buffer_desc);
    buffer_desc.type = .SG_BUFFERTYPE_INDEXBUFFER;
    buffer_desc.size = indices.len * @sizeOf(u16);
    buffer_desc.content = &indices[0];
    state.bindings.index_buffer = sg_make_buffer(&buffer_desc);

    var shader_desc = std.mem.zeroes(sg_shader_desc);
    shader_desc.vs.uniform_blocks[0].size = @sizeOf(VertShaderParams);
    shader_desc.vs.uniform_blocks[0].uniforms[0] = .{
        .name = "mvp",
        .type = .SG_UNIFORMTYPE_MAT4,
        .array_count = 0,
    };
    shader_desc.vs.source = if (std.Target.current.os.tag == .macos) @embedFile("assets/shaders/vertcolor_metal.vs") else @embedFile("assets/shaders/vertcolor_gl.vs");
    shader_desc.fs.source = if (std.Target.current.os.tag == .macos) @embedFile("assets/shaders/vertcolor_metal.fs") else @embedFile("assets/shaders/vertcolor_gl.fs");

    var pipeline_desc = std.mem.zeroes(sg_pipeline_desc);
    pipeline_desc.layout.attrs[0].format = .SG_VERTEXFORMAT_FLOAT3;
    pipeline_desc.layout.attrs[1].format = .SG_VERTEXFORMAT_FLOAT4;
    pipeline_desc.layout.buffers[0].stride = 28;
    pipeline_desc.shader = sg_make_shader(&shader_desc);
    pipeline_desc.index_type = .SG_INDEXTYPE_UINT16;
    pipeline_desc.depth_stencil.depth_compare_func = .SG_COMPAREFUNC_LESS_EQUAL;
    pipeline_desc.depth_stencil.depth_write_enabled = false;
    pipeline_desc.blend.color_format = .SG_PIXELFORMAT_RGBA8;
    pipeline_desc.blend.depth_format = .SG_PIXELFORMAT_NONE;
    pipeline_desc.rasterizer.cull_mode = .SG_CULLMODE_BACK;
    state.pipeline = sg_make_pipeline(&pipeline_desc);
}

fn update() void {
    renderOffscreen();

    if (igBegin("My First Window", null, ImGuiWindowFlags_None)) {
        igText("Hello, world!");
        igText("We get built-in icons too: " ++ icons.igloo);
    }
    igEnd();

    igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
    if (igBegin("Offscreen Rendering", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        ogImage(state.render_texture.imTextureID(), state.render_texture.width, state.render_texture.height);
    }
    igEnd();
    igPopStyleVar(1);
}

var rx: f32 = 0.0;
var ry: f32 = 0.0;

fn renderOffscreen() void {
    var g = state.pass_action.colors[0].val[1] + 0.01;
    if (g > 1) g = 0;
    state.pass_action.colors[0].val[1] = g;

    const radians: f32 = 1.0472; //60 degrees
    var proj = Mat4.createPerspective(radians, @intToFloat(f32, state.render_texture.width) / @intToFloat(f32, state.render_texture.height), 0.01, 100.0);
    var view = Mat4.createLookAt(Vec3.new(2.0, 3.5, 2.0), Vec3.new(0.0, 0.0, 0.0), Vec3.new(0.0, 1.0, 0.0));
    var view_proj = Mat4.mul(proj, view);
    rx += 1.0 / 220.0;
    ry += 2.0 / 220.0;
    var rxm = Mat4.createAngleAxis(Vec3.new(1, 0, 0), rx);
    var rym = Mat4.createAngleAxis(Vec3.new(0, 1, 0), ry);

    var model = Mat4.mul(rxm, rym);
    var mvp = Mat4.mul(view_proj, model);
    var vs_params = VertShaderParams{
        .mvp = mvp,
    };

    sg_begin_pass(state.offscreen_pass, &state.pass_action);
    sg_apply_pipeline(state.pipeline);
    sg_apply_bindings(&state.bindings);
    sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &vs_params, @sizeOf(VertShaderParams));
    sg_draw(0, 36, 1);
    sg_end_pass();
}
