const std = @import("std");

pub const Rect = @import("rect.zig").Rect;
pub const RectI = @import("rect.zig").RectI;
pub const Color = @import("color.zig").Color;
pub const Mat32 = @import("mat32.zig").Mat32;
pub const Mat4 = @import("mat4.zig").Mat4;
pub const Vec2 = @import("vec2.zig").Vec2;
pub const Vec3 = @import("vec3.zig").Vec3;

pub const rand = @import("rand.zig");

/// Converts degrees to radian
pub fn toRadians(deg: anytype) @typeOf(deg) {
    return pi * deg / 180.0;
}

/// Converts radian to degree
pub fn toDegrees(rad: anytype) @typeOf(deg) {
    return 180.0 * rad / pi;
}

pub fn isEven(val: anytype) bool {
    std.debug.assert(@typeInfo(@TypeOf(val)) == .Int or @typeInfo(@TypeOf(val)) == .ComptimeInt);
    return @mod(val, 2) == 0;
}

pub fn ifloor(comptime T: type, val: f32) T {
    return @floatToInt(T, @floor(val));
}

pub fn iclamp(x: i32, a: i32, b: i32) i32 {
    return std.math.max(a, std.math.min(b, x));
}

// returns true if val is between start and end
pub fn between(val: anytype, start: anytype, end: anytype) bool {
    return start <= val and val <= end;
}

test "test math.rand" {
    rand.seed(0);

    std.testing.expect(rand.int(i32) >= 0);

    std.testing.expect(rand.range(i32, 5, 10) >= 5);
    std.testing.expect(rand.range(i32, 5, 10) < 10);

    std.testing.expect(rand.range(u32, 5, 10) >= 5);
    std.testing.expect(rand.range(u32, 5, 10) < 10);

    std.testing.expect(rand.range(f32, 5.0, 10.0) >= 5);
    std.testing.expect(rand.range(f32, 5.0, 10.0) < 10);

    std.testing.expect(rand.uintLessThan(u32, 5) < 5);

    std.testing.expect(isEven(666));
}
