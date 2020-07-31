const std = @import("std");
const upaya = @import("upaya");

const Item = struct {
    /// copy of the data before it was modified
    data: []u8 = undefined,
    /// pointer to data
    ptr: usize = undefined,
    /// size in bytes
    size: usize = undefined,
};

var history = struct {
    undo: std.ArrayList(Item) = undefined,
    redo: std.ArrayList(Item) = undefined,
    temp: std.ArrayList(Item) = undefined,

    pub fn init(self: *@This()) void {
        self.undo = std.ArrayList(Item).init(upaya.mem.allocator);
        self.redo = std.ArrayList(Item).init(upaya.mem.allocator);
        self.temp = std.ArrayList(Item).init(upaya.mem.allocator);
    }

    pub fn deinit(self: @This()) void {
        self.undo.deinit();
        self.redo.deinit();
        self.temp.deinit();
    }

    pub fn reset(self: *@This()) void {
        for (self.undo.items) |item| {
            if (item.size > 0) {
                upaya.mem.allocator.free(item.data);
            }
        }
        for (self.redo.items) |item| {
            if (item.size > 0) {
                upaya.mem.allocator.free(item.data);
            }
        }
        for (self.temp.items) |item| {
            if (item.size > 0) {
                upaya.mem.allocator.free(item.data);
            }
        }

        self.undo.items.len = 0;
        self.redo.items.len = 0;
        self.temp.items.len = 0;
    }
}{};

pub fn init() void {
    history.init();
}

pub fn deinit() void {
    history.undo.deinit();
    history.redo.deinit();
    history.temp.deinit();
}

pub fn push(slice: []u8) void {
    // see if we already have this pointer on our temp stack
    for (history.temp.items) |temp| {
        if (temp.ptr == @ptrToInt(slice.ptr)) return;
    }

    history.temp.append(.{
        .data = std.mem.dupe(upaya.mem.allocator, u8, slice) catch unreachable,
        .ptr = @ptrToInt(slice.ptr),
        .size = slice.len,
    }) catch unreachable;
}

pub fn commit() void {
    var added_commit_boundary = false;
    while (history.temp.popOrNull()) |item| {
        var src = @intToPtr([*]u8, item.ptr);
        if (std.mem.eql(u8, src[0..item.size], item.data)) {
            upaya.mem.allocator.free(item.data);
        } else {
            if (!added_commit_boundary) {
                history.undo.append(.{ .ptr = 0, .size = 0 }) catch unreachable;
                added_commit_boundary = true;
            }

            history.undo.append(item) catch unreachable;
        }
    }
}

pub fn undo() void {
    var added_commit_boundary = false;
    var last_ptr: usize = 0;
    while (history.undo.popOrNull()) |item| {
        if (item.ptr == 0) {
            break;
        }

        if (!added_commit_boundary) {
            history.redo.append(.{ .ptr = 0, .size = 0 }) catch unreachable;
            added_commit_boundary = true;
        }

        var dst = @intToPtr([*]u8, item.ptr);

        // dupe the data currently in the pointer and copy it to our Item so that we can use it for a redo later
        const tmp = std.mem.dupe(upaya.mem.tmp_allocator, u8, dst[0..item.size]) catch unreachable;
        std.mem.copy(u8, dst[0..item.size], item.data);
        std.mem.copy(u8, item.data, tmp);

        history.redo.append(item) catch unreachable;
    }
}

pub fn redo() void {
    var added_commit_boundary = false;
    while (history.redo.popOrNull()) |item| {
        if (item.ptr == 0) {
            return;
        }

        if (!added_commit_boundary) {
            history.undo.append(.{ .ptr = 0, .size = 0 }) catch unreachable;
            added_commit_boundary = true;
        }

        var dst = @intToPtr([*]u8, item.ptr);

        // dupe the data currently in the pointer and copy it to our Item so that we can use it for a undo later
        const tmp = std.mem.dupe(upaya.mem.tmp_allocator, u8, dst[0..item.size]) catch unreachable;
        std.mem.copy(u8, dst[0..item.size], item.data);
        std.mem.copy(u8, item.data, tmp);

        history.undo.append(item) catch unreachable;
    }
}

pub fn reset() void {
    history.reset();
}
