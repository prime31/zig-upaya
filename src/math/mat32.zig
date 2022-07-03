const Vec2 = @import("vec2.zig").Vec2;
const Color = @import("color.zig").Color;
const std = @import("std");
const imgui = @import("imgui");
const math = std.math;

// 3 row, 2 col 2D matrix
//
//  m[0] m[2] m[4]
//  m[1] m[3] m[5]
//
//  0: scaleX    2: sin       4: transX
//  1: cos       3: scaleY    5: transY
//
pub const Mat32 = struct {
    data: [6]f32 = undefined,

    pub const TransformParams = struct { x: f32 = 0, y: f32 = 0, angle: f32 = 0, sx: f32 = 1, sy: f32 = 1, ox: f32 = 0, oy: f32 = 0 };

    pub const identity = Mat32{ .data = .{ 1, 0, 0, 1, 0, 0 } };

    pub fn format(self: Mat32, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        return writer.print("{d:0.6}, {d:0.6}, {d:0.6}, {d:0.6}, {d:0.6}, {d:0.6}", .{ self.data[0], self.data[1], self.data[2], self.data[3], self.data[4], self.data[5] });
    }

    pub fn init() Mat32 {
        return identity;
    }

    pub fn initTransform(vals: TransformParams) Mat32 {
        var mat = Mat32{};
        mat.setTransform(vals);
        return mat;
    }

    pub fn initOrtho(width: f32, height: f32) Mat32 {
        var result = Mat32{};
        result.data[0] = 2 / width;
        result.data[3] = -2 / height;
        result.data[4] = -1;
        result.data[5] = 1;
        return result;
    }

    pub fn initOrthoOffCenter(width: f32, height: f32) Mat32 {
        const half_w = @ceil(width / 2);
        const half_h = @ceil(height / 2);

        var result = identity;
        result.data[0] = 2.0 / (half_w + half_w);
        result.data[3] = 2.0 / (-half_h - half_h);
        result.data[4] = (-half_w + half_w) / (-half_w - half_w);
        result.data[5] = (half_h - half_h) / (half_h + half_h);
        return result;
    }

    pub fn setTransform(self: *Mat32, vals: TransformParams) void {
        const c = math.cos(vals.angle);
        const s = math.sin(vals.angle);

        // matrix multiplication carried out on paper:
        // |1    x| |c -s  | |sx     | |1   -ox|
        // |  1  y| |s  c  | |   sy  | |  1 -oy|
        //   move    rotate    scale     origin
        self.data[0] = c * vals.sx;
        self.data[1] = s * vals.sx;
        self.data[2] = -s * vals.sy;
        self.data[3] = c * vals.sy;
        self.data[4] = vals.x - vals.ox * self.data[0] - vals.oy * self.data[2];
        self.data[5] = vals.y - vals.ox * self.data[1] - vals.oy * self.data[3];
    }

    pub fn mul(self: Mat32, r: Mat32) Mat32 {
        var result = Mat32{};
        result.data[0] = self.data[0] * r.data[0] + self.data[2] * r.data[1];
        result.data[1] = self.data[1] * r.data[0] + self.data[3] * r.data[1];
        result.data[2] = self.data[0] * r.data[2] + self.data[2] * r.data[3];
        result.data[3] = self.data[1] * r.data[2] + self.data[3] * r.data[3];
        result.data[4] = self.data[0] * r.data[4] + self.data[2] * r.data[5] + self.data[4];
        result.data[5] = self.data[1] * r.data[4] + self.data[3] * r.data[5] + self.data[5];
        return result;
    }

    pub fn translate(self: *Mat32, x: f32, y: f32) void {
        self.data[4] = self.data[0] * x + self.data[2] * y + self.data[4];
        self.data[5] = self.data[1] * x + self.data[3] * y + self.data[5];
    }

    pub fn rotate(self: *Mat32, rads: f32) void {
        const cos = math.cos(rads);
        const sin = math.sin(rads);

        const nm0 = self.data[0] * cos + self.data[2] * sin;
        const nm1 = self.data[1] * cos + self.data[3] * sin;

        self.data[2] = self.data[0] * -sin + self.data[2] * cos;
        self.data[3] = self.data[1] * -sin + self.data[3] * cos;
        self.data[0] = nm0;
        self.data[1] = nm1;
    }

    pub fn scale(self: *Mat32, x: f32, y: f32) void {
        self.data[0] *= x;
        self.data[1] *= x;
        self.data[2] *= y;
        self.data[3] *= y;
    }

    pub fn determinant(self: Mat32) f32 {
        return self.data[0] * self.data[3] - self.data[2] * self.data[1];
    }

    pub fn inverse(self: Mat32) Mat32 {
        var res = std.mem.zeroes(Mat32);
        const s = 1.0 / self.determinant();
        res.data[0] = self.data[3] * s;
        res.data[1] = -self.data[1] * s;
        res.data[2] = -self.data[2] * s;
        res.data[3] = self.data[0] * s;
        res.data[4] = (self.data[5] * self.data[2] - self.data[4] * self.data[3]) * s;
        res.data[5] = -(self.data[5] * self.data[0] - self.data[4] * self.data[1]) * s;

        return res;
    }

    pub fn transformVec2(self: Mat32, pos: Vec2) Vec2 {
        return .{
            .x = pos.x * self.data[0] + pos.y * self.data[2] + self.data[4],
            .y = pos.x * self.data[1] + pos.y * self.data[3] + self.data[5],
        };
    }

    pub fn transformImVec2(self: Mat32, pos: imgui.ImVec2) imgui.ImVec2 {
        return .{
            .x = pos.x * self.data[0] + pos.y * self.data[2] + self.data[4],
            .y = pos.x * self.data[1] + pos.y * self.data[3] + self.data[5],
        };
    }

    pub fn transformVec2Slice(self: Mat32, comptime T: type, dst: []T, src: []Vec2) void {
        for (src) |_, i| {
            const x = src[i].x * self.data[0] + src[i].y * self.data[2] + self.data[4];
            const y = src[i].x * self.data[1] + src[i].y * self.data[3] + self.data[5];
            dst[i].x = x;
            dst[i].y = y;
        }
    }
};

test "mat32 tests" {
    // const i = Mat32.identity;
    const mat1 = Mat32.initTransform(.{ .x = 10, .y = 10 });
    var mat2 = Mat32{};
    mat2.setTransform(.{ .x = 10, .y = 10 });
    std.testing.expectEqual(mat2, mat1);

    var mat3 = Mat32.init();
    mat3.setTransform(.{ .x = 10, .y = 10 });
    std.testing.expectEqual(mat3, mat1);

    // const mat4 = Mat32.initOrtho(640, 480);
    // const mat5 = Mat32.initOrthoOffCenter(640, 480);

    var mat6 = Mat32.init();
    mat6.translate(10, 20);
    std.testing.expectEqual(mat6.data[4], 10);
}

test "mat32 transform tests" {
    const i = Mat32.identity;
    const vec = Vec2.init(44, 55);
    const vec_t = i.transformVec2(vec);
    std.testing.expectEqual(vec, vec_t);
}

test "mat32 as camera transform" {
    const mat = Mat32.initTransform(.{ .x = 10, .y = 10, .sx = 1, .sy = 1 });
    const mat_inv = mat.inverse();
    // const vec = Vec2.init(0, 0);
    // const vec_t = mat.transformVec2(vec);

    std.debug.print("\n-- transform  0, 0: {d}\n", .{mat_inv.transformVec2(.{ .x = 0, .y = 0 })});
    std.debug.print("-- transform 10,10: {d}\n", .{mat_inv.transformVec2(.{ .x = 10, .y = 10 })});
    std.debug.print("-- transform 20,20: {d}\n", .{mat_inv.transformVec2(.{ .x = 20, .y = 20 })});
}
