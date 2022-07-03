pub const Edge = enum(u8) {
    right,
    left,
    top,
    bottom,

    pub fn opposing(self: Edge) Edge {
        return switch (self) {
            .right => .left,
            .left => .right,
            .top => .bottom,
            .bottom => .top,
        };
    }

    pub fn horizontal(self: Edge) bool {
        return self == .right or self == .left;
    }

    pub fn vertical(self: Edge) bool {
        return self == .top or self == .bottom;
    }

    pub fn max(self: Edge) bool {
        return self == .right or self == .bottom;
    }
};
