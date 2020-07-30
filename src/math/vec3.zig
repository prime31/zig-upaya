const std = @import("std");

// sourced from https://github.com/jeffkdev/sokol-zig-examples
pub const Vec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn length2(a: Vec3) f32 {
        return Vec3.dot(a, a);
    }
    pub fn length(a: Vec3) f32 {
        return std.math.sqrt(a.length2());
    }
    pub fn dot(a: Vec3, b: Vec3) f32 {
        var result: f32 = 0;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            result += @field(a, fld.name) * @field(b, fld.name);
        }
        return result;
    }
    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }
    pub fn scale(a: Vec3, b: f32) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) * b;
        }
        return result;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn normalize(vec: Vec3) Vec3 {
        return vec.scale(1.0 / vec.length());
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) - @field(b, fld.name);
        }
        return result;
    }
};
