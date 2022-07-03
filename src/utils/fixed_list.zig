const std = @import("std");

/// fixed size array wrapper that provides ArrayList-like semantics. Appending more items than fit in the
/// list ignores the item and logs a warning. Use the FixedList.len field to get the actual number of items present.
pub fn FixedList(comptime T: type, comptime len: usize) type {
    return struct {
        const Self = @This();

        items: [len]T = undefined,
        len: usize = 0,

        pub const Iterator = struct {
            list: Self,
            index: usize = 0,

            pub fn next(self: *Iterator) ?T {
                if (self.index == self.list.len) return null;
                var next_item = self.list.items[self.index];
                self.index += 1;
                return next_item;
            }
        };

        pub fn init() Self {
            return Self{ .items = [_]T{0} ** len };
        }

        pub fn initWithValue(comptime value: T) Self {
            return Self{ .items = [_]T{value} ** len };
        }

        pub fn append(self: *Self, item: T) void {
            if (self.len == self.items.len) {
                std.log.warn("attemped to append to a full FixedList\n", .{});
                return;
            }
            self.items[self.len] = item;
            self.len += 1;
        }

        pub fn clear(self: *Self) void {
            self.len = 0;
        }

        pub fn pop(self: *Self) T {
            var item = self.items[self.len - 1];
            self.len -= 1;
            return item;
        }

        pub fn contains(self: Self, value: T) bool {
            return self.indexOf(value) != null;
        }

        pub fn indexOf(self: Self, value: T) ?usize {
            var i: usize = 0;
            while (i < self.len) : (i += 1) {
                if (self.items[i] == value) return i;
            }
            return null;
        }

        /// Removes the element at the specified index and returns it. The empty slot is filled from the end of the list.
        pub fn swapRemove(self: *Self, i: usize) T {
            if (self.len - 1 == i) return self.pop();

            const old_item = self.items[i];
            self.items[i] = self.pop();
            return old_item;
        }

        pub fn iter(self: Self) Iterator {
            return Iterator{ .list = self };
        }
    };
}

test "fixed list" {
    var list = FixedList(u32, 4).init();
    list.append(4);
    std.testing.expectEqual(list.len, 1);

    list.append(46);
    list.append(146);
    list.append(4456);
    std.testing.expectEqual(list.len, 4);

    _ = list.pop();
    std.testing.expectEqual(list.len, 3);

    list.clear();
    std.testing.expectEqual(list.len, 0);
}
