const std = @import("std");
const aya = @import("../upaya.zig");

pub const Markov = struct {
    rows: std.StringHashMap(std.StringHashMap(u8)),
    firsts: std.StringHashMap(u8),
    final: []u8 = undefined,
    arena: std.heap.ArenaAllocator,

    pub fn init() Markov {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        return .{
            .rows = std.StringHashMap(std.StringHashMap(u8)).init(&arena.allocator),
            .firsts = std.StringHashMap(u8).init(&arena.allocator),
            .arena = arena,
        };
    }

    pub fn deinit(self: *Markov) void {
        self.arena.deinit();
    }

    fn choose(hashmap: std.StringHashMap(u8)) []const u8 {
        var n: i32 = 0;
        for (hashmap.items()) |entry| {
            n += @intCast(i32, entry.value);
        }

        if (n <= 1) return hashmap.items()[0].key;

        n = aya.math.rand.range(i32, 0, n);
        for (hashmap.items()) |entry| {
            n = n - @intCast(i32, entry.value);
            if (n < 0) return entry.key;
        }

        unreachable;
    }

    pub fn generateChain(data: []const u8, width: usize, height: usize) []const u8 {
        aya.math.rand.seed(@intCast(u64, std.time.milliTimestamp()));

        var markov = Markov.init();
        defer markov.deinit();

        markov.addSourceMap(data, width, height);

        var res = std.ArrayList([]const u8).init(&markov.arena.allocator);
        var item = choose(markov.firsts);
        while (!std.mem.eql(u8, item, markov.final)) {
            res.append(item) catch unreachable;
            item = choose(markov.rows.get(item).?);
        }

        var new_map = markov.arena.allocator.alloc(u8, res.items.len * width) catch unreachable;
        var i: usize = 0;
        for (res.items) |row| {
            for (row) |tile| {
                new_map[i] = tile;
                i += 1;
            }
        }

        return markov.generate(20);
    }

    pub fn generate(self: *Markov, min_rows: usize) []const u8 {
        var res = std.ArrayList([]const u8).init(&self.arena.allocator);

        var item = choose(self.firsts);
        while (res.items.len < min_rows) {
            while (!std.mem.eql(u8, item, self.final)) {
                res.append(item) catch unreachable;
                item = choose(self.rows.get(item).?);
            }
            // reset item for the next iteration
            item = choose(self.rows.items()[aya.math.rand.range(usize, 0, self.rows.items().len)].value);
        }
        res.append(self.final) catch unreachable;

        var new_map = aya.mem.allocator.alloc(u8, res.items.len * res.items[0].len) catch unreachable;
        var i: usize = 0;
        for (res.items) |row| {
            for (row) |tile| {
                new_map[i] = tile;
                i += 1;
            }
        }

        return new_map;
    }

    pub fn addSourceMap(self: *Markov, data: []const u8, width: usize, height: usize) void {
        var all_rows = self.arena.allocator.alloc([]u8, height) catch unreachable;

        var y: usize = 0;
        while (y < height) : (y += 1) {
            var current_row = self.arena.allocator.alloc(u8, width) catch unreachable;
            var x: usize = 0;
            while (x < width) : (x += 1) {
                current_row[x] = data[x + y * width];
            }
            all_rows[y] = current_row;
        }

        incrementItemCount(&self.firsts, all_rows[0]);
        for (all_rows) |row, i| {
            if (i == 0) continue;
            self.updateItem(all_rows[i - 1], row);
        }

        self.final = all_rows[all_rows.len - 1];
        self.updateItem(self.final, self.final);
    }

    fn incrementItemCount(hashmap: *std.StringHashMap(u8), row: []u8) void {
        var res = hashmap.getOrPut(row) catch unreachable;
        if (!res.found_existing) {
            res.entry.value = 1;
        } else {
            res.entry.value += 1;
        }
    }

    fn updateItem(self: *Markov, item: []u8, next: []u8) void {
        var entry = self.rows.getOrPut(item) catch unreachable;
        if (!entry.found_existing) {
            entry.entry.value = std.StringHashMap(u8).init(&self.arena.allocator);
        }
        incrementItemCount(&entry.entry.value, next);
    }
};
