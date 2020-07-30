const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

// sourced from https://github.com/jeffkdev/sokol-zig-examples
pub const Mat4 = extern struct {
    fields: [4][4]f32, // [col][row]

    pub const zero = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
        },
    };

    pub const identity = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 1, 0, 0, 0 },
            [4]f32{ 0, 1, 0, 0 },
            [4]f32{ 0, 0, 1, 0 },
            [4]f32{ 0, 0, 0, 1 },
        },
    };

    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        var result: Mat4 = undefined;
        inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
            inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
                var sum: f32 = 0.0;
                inline for ([_]comptime_int{ 0, 1, 2, 3 }) |i| {
                    sum += a.fields[i][row] * b.fields[col][i];
                }
                result.fields[col][row] = sum;
            }
        }
        return result;
    }
    // taken from GLM implementation
    pub fn createLook(eye: Vec3, direction: Vec3, up: Vec3) Mat4 {
        const f = direction.normalize();
        const s = Vec3.cross(up, f).normalize();
        const u = Vec3.cross(f, s);

        var result = Mat4.identity;
        result.fields[0][0] = s.x;
        result.fields[1][0] = s.y;
        result.fields[2][0] = s.z;
        result.fields[0][1] = u.x;
        result.fields[1][1] = u.y;
        result.fields[2][1] = u.z;
        result.fields[0][2] = f.x;
        result.fields[1][2] = f.y;
        result.fields[2][2] = f.z;
        result.fields[3][0] = -Vec3.dot(s, eye);
        result.fields[3][1] = -Vec3.dot(u, eye);
        result.fields[3][2] = -Vec3.dot(f, eye);
        return result;
    }

    pub fn createLookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
        return createLook(eye, Vec3.sub(eye, center), up);
    }

    // taken from GLM implementation
    pub fn createPerspective(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
        std.debug.assert(std.math.fabs(aspect - 0.001) > 0);
        std.debug.assert(far > near);
        const tanHalfFov = std.math.tan(fov / 2);

        var result = Mat4.zero;
        result.fields[0][0] = 1.0 / (aspect * tanHalfFov);
        result.fields[1][1] = 1.0 / (tanHalfFov);
        result.fields[2][2] = -(far + near) / (far - near);
        result.fields[2][3] = -1.0;
        result.fields[3][2] = -(2.0 * far * near) / (far - near);
        return result;
    }

    pub fn createAngleAxis(axis: Vec3, angle: f32) Mat4 {
        var cos = std.math.cos(angle);
        var sin = std.math.sin(angle);
        var x = axis.x;
        var y = axis.y;
        var z = axis.z;

        return .{
            .fields = [4][4]f32{
                [4]f32{ cos + x * x * (1 - cos), x * y * (1 - cos) - z * sin, x * z * (1 - cos) + y * sin, 0 },
                [4]f32{ y * x * (1 - cos) + z * sin, cos + y * y * (1 - cos), y * z * (1 - cos) - x * sin, 0 },
                [4]f32{ z * x * (1 * cos) - y * sin, z * y * (1 - cos) + x * sin, cos + z * z * (1 - cos), 0 },
                [4]f32{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn createOrthogonal(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
        var result = Mat4.identity;
        result.fields[0][0] = 2 / (right - left);
        result.fields[1][1] = 2 / (top - bottom);
        result.fields[2][2] = 1 / (far - near);
        result.fields[3][0] = -(right + left) / (right - left);
        result.fields[3][1] = -(top + bottom) / (top - bottom);
        result.fields[3][2] = -near / (far - near);
        return result;
    }

    pub fn toArray(m: Mat4) [16]f32 {
        var result: [16]f32 = undefined;
        var i: usize = 0;
        inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
            inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
                result[i] = m.fields[col][row];
                i += 1;
            }
        }
        return result;
    }
};
