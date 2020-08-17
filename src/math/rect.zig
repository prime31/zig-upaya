const std = @import("std");
const Edge = @import("edge.zig").Edge;

pub const Rect = struct {
    x: f32 = 0,
    y: f32 = 0,
    w: f32 = 0,
    h: f32 = 0,
};

pub const RectI = struct {
    x: i32 = 0,
    y: i32 = 0,
    w: i32 = 0,
    h: i32 = 0,

    pub fn right(self: RectI) i32 {
        return self.x + self.w;
    }

    pub fn left(self: RectI) i32 {
        return self.x;
    }

    pub fn top(self: RectI) i32 {
        return self.y;
    }

    pub fn bottom(self: RectI) i32 {
        return self.y + self.h;
    }

    pub fn centerX(self: RectI) i32 {
        return self.x + @divTrunc(self.w, 2);
    }

    pub fn centerY(self: RectI) i32 {
        return self.y + @divTrunc(self.h, 2);
    }

    pub fn halfRect(self: RectI, edge: Edge) RectI {
        return switch (edge) {
            .top => RectI{ .x = self.x, .y = self.y, .w = self.w, .h = @divTrunc(self.h, 2) },
            .bottom => RectI{ .x = self.x, .y = self.y + @divTrunc(self.h, 2), .w = self.w, .h = @divTrunc(self.h, 2) },
            .left => RectI{ .x = self.x, .y = self.y, .w = @divTrunc(self.w, 2), .h = self.h },
            .right => RectI{ .x = self.x + @divTrunc(self.w, 2), .y = self.y, .w = @divTrunc(self.w, 2), .h = self.h },
        };
    }

    pub fn contract(self: *RectI, horiz: i32, vert: i32) void {
        self.x += horiz;
        self.y += vert;
        self.w -= horiz * 2;
        self.h -= vert * 2;
    }

    pub fn expandEdge(self: *RectI, edge: Edge, move_x: i32) void {
        const amt = std.math.absInt(move_x) catch unreachable;

        switch (edge) {
            .top => {
                self.y -= amt;
                self.h += amt;
            },
            .bottom => {
                self.h += amt;
            },
            .left => {
                self.x -= amt;
                self.w += amt;
            },
            .right => {
                self.w += amt;
            },
        }
    }

    pub fn side(self: RectI, edge: Edge) i32 {
        return switch (edge) {
            .left => self.x,
            .right => self.x + self.w,
            .top => self.y,
            .bottom => self.y + self.h,
        };
    }

    pub fn contains(self: RectI, x: i32, y: i32) bool {
        return self.x <= x and x < self.right() and self.y <= y and y < self.bottom();
    }

    pub fn asRect(self: RectI) Rect {
        return .{
            .x = @intToFloat(f32, self.x),
            .y = @intToFloat(f32, self.y),
            .w = @intToFloat(f32, self.w),
            .h = @intToFloat(f32, self.h),
        };
    }
};
