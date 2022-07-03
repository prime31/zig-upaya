const std = @import("std");
const upaya = @import("upaya");

pub const Map = struct {
    w: usize = 64,
    h: usize = 64,
    tile_size: usize = 16,
    tile_spacing: usize = 0,
    image: []const u8 = "",
    data: []u8,
    ruleset: RuleSet,
    ruleset_groups: std.AutoHashMap(u8, []const u8),
    pre_rulesets: std.ArrayList(RuleSet),
    tags: std.ArrayList(Tag),
    tile_definitions: TileDefinitions,
    objects: std.ArrayList(Object),
    animations: std.ArrayList(Animation),

    pub fn init(tile_size: usize, tile_spacing: usize) Map {
        var map = .{
            .w = 64,
            .h = 64,
            .tile_size = tile_size,
            .tile_spacing = tile_spacing,
            .data = upaya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .ruleset = RuleSet.init(),
            .ruleset_groups = std.AutoHashMap(u8, []const u8).init(upaya.mem.allocator),
            .pre_rulesets = std.ArrayList(RuleSet).init(upaya.mem.allocator),
            .tags = std.ArrayList(Tag).init(upaya.mem.allocator),
            .tile_definitions = .{},
            .objects = std.ArrayList(Object).init(upaya.mem.allocator),
            .animations = std.ArrayList(Animation).init(upaya.mem.allocator),
        };

        std.mem.set(u8, map.data, 0);
        return map;
    }

    pub fn deinit(self: *Map) void {
        upaya.mem.allocator.free(self.data);
        for (self.pre_rulesets.items) |pr| {
            pr.deinit();
        }
        self.ruleset.deinit();
        self.ruleset_groups.deinit();
        self.tags.deinit();
        self.objects.deinit();
        self.animations.deinit();

        if (self.image.len > 0) {
            upaya.mem.allocator.free(self.image);
        }
    }

    pub fn addTag(self: *Map) void {
        self.tags.append(Tag.init()) catch unreachable;
    }

    pub fn addObject(self: *Map) void {
        var obj = Object.init(self.objects.items.len);
        _ = std.fmt.bufPrint(&obj.name, "Object ${}", .{self.objects.items.len}) catch unreachable;
        obj.name[8 + 1 + @divTrunc(self.objects.items.len, 10)] = 0;
        self.objects.append(obj) catch unreachable;
    }

    pub fn getObjectWithId(self: Map, id: usize) Object {
        for (self.objects.items) |obj| {
            if (obj.id == id) return obj;
        }
        unreachable;
    }

    pub fn getGroupName(self: Map, group: u8) []const u8 {
        return self.ruleset_groups.get(group) orelse "Unnamed Group";
    }

    pub fn renameGroup(self: *Map, group: u8, name: []const u8) void {
        if (self.ruleset_groups.fetchRemove(group)) |entry| {
            upaya.mem.allocator.free(entry.value);
        }
        self.ruleset_groups.put(group, upaya.mem.allocator.dupe(u8, name) catch unreachable) catch unreachable;
    }

    pub fn removeGroupIfEmpty(self: *Map, group: u8) void {
        for (self.ruleset.rules.items) |rule| {
            if (rule.group == group) return;
        }
        if (self.ruleset_groups.fetchRemove(group)) |entry| {
            upaya.mem.allocator.free(entry.value);
        }
    }

    pub fn addAnimation(self: *Map, tile: u8) void {
        self.animations.append(Animation.init(tile)) catch unreachable;
    }

    pub fn tryGetAnimation(self: *Map, tile: u8) ?Animation {
        for (self.animations.items) |anim| {
            if (anim.tile == tile) return anim;
        }
        return null;
    }

    pub fn addPreRuleSet(self: *Map) void {
        self.pre_rulesets.append(RuleSet.init()) catch unreachable;
    }

    pub fn getTile(self: Map, x: usize, y: usize) u8 {
        if (x > self.w or y > self.h) {
            return 0;
        }
        return self.data[x + y * self.w];
    }

    pub fn setTile(self: Map, x: usize, y: usize, value: u8) void {
        self.data[x + y * self.w] = value;
    }
};

pub const RuleSet = struct {
    seed: u64 = 0,
    repeat: u8 = 20,
    rules: std.ArrayList(Rule),

    pub fn init() RuleSet {
        return .{ .rules = std.ArrayList(Rule).init(upaya.mem.allocator) };
    }

    pub fn deinit(self: RuleSet) void {
        self.rules.deinit();
    }

    pub fn addRule(self: *RuleSet) void {
        self.rules.append(Rule.init()) catch unreachable;
    }

    pub fn getNextAvailableGroup(self: RuleSet, map: *Map, name: []const u8) u8 {
        var group: u8 = 0;
        for (self.rules.items) |rule| {
            group = std.math.max(group, rule.group);
        }
        map.ruleset_groups.put(group + 1, upaya.mem.allocator.dupe(u8, name) catch unreachable) catch unreachable;
        return group + 1;
    }

    /// adds the Rules required for a nine-slice with index being the top-left element of the nine-slice
    pub fn addNinceSliceRules(self: *RuleSet, map: *Map, tiles_per_row: usize, selected_brush_index: usize, name_prefix: []const u8, index: usize) void {
        const x = @mod(index, tiles_per_row);
        const y = @divTrunc(index, tiles_per_row);
        const group = self.getNextAvailableGroup(map, name_prefix);

        var rule = Rule.init();
        rule.group = group;
        const tl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tl_name);
        rule.get(1, 2).negate(selected_brush_index + 1);
        rule.get(2, 1).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + y * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const tr_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tr" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tr_name);
        rule.get(3, 2).negate(selected_brush_index + 1);
        rule.get(2, 1).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 2 + y * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const bl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-bl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, bl_name);
        rule.get(1, 2).negate(selected_brush_index + 1);
        rule.get(2, 3).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + (y + 2) * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const br_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-br" }) catch unreachable;
        std.mem.copy(u8, &rule.name, br_name);
        rule.get(2, 3).negate(selected_brush_index + 1);
        rule.get(3, 2).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 2 + (y + 2) * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const t_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-t" }) catch unreachable;
        std.mem.copy(u8, &rule.name, t_name);
        rule.get(2, 1).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + y * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const b_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-b" }) catch unreachable;
        std.mem.copy(u8, &rule.name, b_name);
        rule.get(2, 3).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + (y + 2) * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const l_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-l" }) catch unreachable;
        std.mem.copy(u8, &rule.name, l_name);
        rule.get(1, 2).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + (y + 1) * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const r_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-r" }) catch unreachable;
        std.mem.copy(u8, &rule.name, r_name);
        rule.get(3, 2).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, (x + 2) + (y + 1) * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const c_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-c" }) catch unreachable;
        std.mem.copy(u8, &rule.name, c_name);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + (y + 1) * tiles_per_row));
        self.rules.append(rule) catch unreachable;
    }

    pub fn addInnerFourRules(self: *RuleSet, map: *Map, tiles_per_row: usize, selected_brush_index: usize, name_prefix: []const u8, index: usize) void {
        const x = @mod(index, tiles_per_row);
        const y = @divTrunc(index, tiles_per_row);
        const group = self.getNextAvailableGroup(map, name_prefix);

        var rule = Rule.init();
        rule.group = group;
        const tl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tl_name);
        rule.get(1, 1).negate(selected_brush_index + 1);
        rule.get(1, 2).require(selected_brush_index + 1);
        rule.get(2, 1).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + y * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const tr_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tr" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tr_name);
        rule.get(3, 1).negate(selected_brush_index + 1);
        rule.get(3, 2).require(selected_brush_index + 1);
        rule.get(2, 1).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + y * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const bl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-bl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, bl_name);
        rule.get(1, 2).require(selected_brush_index + 1);
        rule.get(2, 3).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.get(1, 3).negate(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + (y + 1) * tiles_per_row));
        self.rules.append(rule) catch unreachable;

        rule = Rule.init();
        rule.group = group;
        const br_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-br" }) catch unreachable;
        std.mem.copy(u8, &rule.name, br_name);
        rule.get(2, 3).require(selected_brush_index + 1);
        rule.get(3, 2).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.get(3, 3).negate(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + (y + 1) * tiles_per_row));
        self.rules.append(rule) catch unreachable;
    }

    pub fn addFloodFill(self: *RuleSet, selected_brush_index: usize, name_prefix: []const u8, left: bool, right: bool, up: bool, down: bool) void {
        if (left) {
            var rule = Rule.init();
            const tl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-l" }) catch unreachable;
            std.mem.copy(u8, &rule.name, tl_name);

            rule.get(2, 2).require(0);
            rule.get(3, 2).require(selected_brush_index + 1);
            rule.toggleSelected(@intCast(u8, selected_brush_index));
            self.rules.append(rule) catch unreachable;
        }

        if (right) {
            var rule = Rule.init();
            const tl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-r" }) catch unreachable;
            std.mem.copy(u8, &rule.name, tl_name);

            rule.get(2, 2).require(0);
            rule.get(1, 2).require(selected_brush_index + 1);
            rule.toggleSelected(@intCast(u8, selected_brush_index));
            self.rules.append(rule) catch unreachable;
        }

        if (up) {
            var rule = Rule.init();
            const tl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-u" }) catch unreachable;
            std.mem.copy(u8, &rule.name, tl_name);

            rule.get(2, 2).require(0);
            rule.get(2, 3).require(selected_brush_index + 1);
            rule.toggleSelected(@intCast(u8, selected_brush_index));
            self.rules.append(rule) catch unreachable;
        }

        if (down) {
            var rule = Rule.init();
            const tl_name = std.mem.concat(upaya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-d" }) catch unreachable;
            std.mem.copy(u8, &rule.name, tl_name);

            rule.get(2, 2).require(0);
            rule.get(2, 1).require(selected_brush_index + 1);
            rule.toggleSelected(@intCast(u8, selected_brush_index));
            self.rules.append(rule) catch unreachable;
        }
    }
};

pub const Rule = struct {
    name: [25:0]u8 = [_:0]u8{0} ** 25,
    rule_tiles: [25]RuleTile = undefined,
    chance: u8 = 100,
    result_tiles: upaya.FixedList(u8, 25), // indices into the tileset image
    group: u8 = 0, // UI-relevant: used to group Rules into a tree leaf node visually

    pub fn init() Rule {
        return .{
            .rule_tiles = [_]RuleTile{RuleTile{ .tile = 0, .state = .none }} ** 25,
            .result_tiles = upaya.FixedList(u8, 25).init(),
        };
    }

    pub fn clone(self: Rule) Rule {
        var new_rule = Rule.init();
        std.mem.copy(u8, &new_rule.name, &self.name);
        std.mem.copy(RuleTile, &new_rule.rule_tiles, &self.rule_tiles);
        std.mem.copy(u8, &new_rule.result_tiles.items, &self.result_tiles.items);
        new_rule.result_tiles.len = self.result_tiles.len;
        new_rule.chance = self.chance;
        new_rule.group = self.group;
        return new_rule;
    }

    pub fn clearPatternData(self: *Rule) void {
        self.rule_tiles = [_]RuleTile{RuleTile{ .tile = 0, .state = .none }} ** 25;
    }

    pub fn get(self: *Rule, x: usize, y: usize) *RuleTile {
        return &self.rule_tiles[x + y * 5];
    }

    pub fn resultTile(self: *Rule, random: usize) usize {
        const index = std.rand.limitRangeBiased(usize, random, self.result_tiles.len);
        return self.result_tiles.items[index];
    }

    pub fn toggleSelected(self: *Rule, index: u8) void {
        if (self.result_tiles.indexOf(index)) |slice_index| {
            _ = self.result_tiles.swapRemove(slice_index);
        } else {
            self.result_tiles.append(index);
        }
    }

    pub fn flip(self: *Rule, dir: enum { horizontal, vertical }) void {
        if (dir == .vertical) {
            for ([_]usize{ 0, 1 }) |y| {
                for ([_]usize{ 0, 1, 2, 3, 4 }) |x| {
                    std.mem.swap(RuleTile, &self.rule_tiles[x + y * 5], &self.rule_tiles[x + (4 - y) * 5]);
                }
            }
        } else {
            for ([_]usize{ 0, 1 }) |x| {
                for ([_]usize{ 0, 1, 2, 3, 4 }) |y| {
                    std.mem.swap(RuleTile, &self.rule_tiles[x + y * 5], &self.rule_tiles[(4 - x) + y * 5]);
                }
            }
        }
    }

    pub fn shift(self: *Rule, dir: enum { left, right, up, down }) void {
        var x_incr: i32 = if (dir == .left) -1 else 1;
        var x_vals = [_]usize{ 0, 1, 2, 3, 4 };
        if (dir == .right) std.mem.reverse(usize, &x_vals);

        var y_incr: i32 = if (dir == .up) -1 else 1;
        var y_vals = [_]usize{ 0, 1, 2, 3, 4 };
        if (dir == .down) std.mem.reverse(usize, &y_vals);

        if (dir == .left or dir == .right) {
            for (y_vals) |y| {
                for (x_vals) |x| {
                    self.swap(x, y, @intCast(i32, x) + x_incr, @intCast(i32, y));
                }
            }
        } else {
            for (x_vals) |x| {
                for (y_vals) |y| {
                    self.swap(x, y, @intCast(i32, x), @intCast(i32, y) + y_incr);
                }
            }
        }
    }

    fn swap(self: *Rule, x: usize, y: usize, new_x: i32, new_y: i32) void {
        // destinations can be invalid and when they are we just reset the source values
        if (new_x >= 0 and new_x < 5 and new_y >= 0 and new_y < 5) {
            self.rule_tiles[@intCast(usize, new_x + new_y * 5)] = self.rule_tiles[x + y * 5].clone();
        }
        self.rule_tiles[x + y * 5].reset();
    }
};

pub const RuleTile = struct {
    tile: usize = 0,
    state: RuleState = .none,

    pub const RuleState = enum(u4) {
        none,
        negated,
        required,
    };

    pub fn clone(self: RuleTile) RuleTile {
        return .{ .tile = self.tile, .state = self.state };
    }

    pub fn reset(self: *RuleTile) void {
        self.tile = 0;
        self.state = .none;
    }

    pub fn passes(self: RuleTile, tile: usize) bool {
        if (self.state == .none) return false;
        if (tile == self.tile) {
            return self.state == .required;
        }
        return self.state == .negated;
    }

    pub fn toggleState(self: *RuleTile, new_state: RuleState) void {
        if (self.tile == 0) {
            self.state = new_state;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }

    pub fn negate(self: *RuleTile, index: usize) void {
        if (self.tile == 0) {
            self.tile = index;
            self.state = .negated;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }

    pub fn require(self: *RuleTile, index: usize) void {
        if (self.tile == 0) {
            self.tile = index;
            self.state = .required;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }
};

pub const Tag = struct {
    name: [25]u8,
    tiles: upaya.FixedList(u8, 10),

    pub fn init() Tag {
        return .{ .name = [_]u8{0} ** 25, .tiles = upaya.FixedList(u8, 10).init() };
    }

    pub fn toggleSelected(self: *Tag, index: u8) void {
        if (self.tiles.indexOf(index)) |slice_index| {
            _ = self.tiles.swapRemove(slice_index);
        } else {
            self.tiles.append(index);
        }
    }
};

pub const TileDefinitions = struct {
    solid: upaya.FixedList(u8, 50) = upaya.FixedList(u8, 50).init(),
    slope_down: upaya.FixedList(u8, 10) = upaya.FixedList(u8, 10).init(),
    slope_down_steep: upaya.FixedList(u8, 10) = upaya.FixedList(u8, 10).init(),
    slope_up: upaya.FixedList(u8, 10) = upaya.FixedList(u8, 10).init(),
    slope_up_steep: upaya.FixedList(u8, 10) = upaya.FixedList(u8, 10).init(),

    pub fn toggleSelected(tiles: anytype, index: u8) void {
        if (tiles.indexOf(index)) |slice_index| {
            _ = tiles.swapRemove(slice_index);
        } else {
            tiles.append(index);
        }
    }
};

pub const Object = struct {
    id: u8 = 0,
    name: [25]u8 = undefined,
    x: usize = 0,
    y: usize = 0,
    props: std.ArrayList(Prop),

    pub const Prop = struct {
        name: [25]u8,
        value: PropValue,

        pub fn init() Prop {
            return .{ .name = [_]u8{0} ** 25, .value = undefined };
        }
    };

    pub const PropValue = union(enum) {
        string: [25]u8,
        int: i32,
        float: f32,
        link: u8,
    };

    pub fn init(id: usize) Object {
        var obj = Object{ .name = [_]u8{0} ** 25, .id = @intCast(u8, id), .props = std.ArrayList(Prop).init(upaya.mem.allocator) };
        _ = std.fmt.bufPrint(&obj.name, "Object ${}", .{id}) catch unreachable;
        obj.name[8 + 1 + @divTrunc(id, 10)] = 0;
        return obj;
    }

    pub fn deinit(self: Object) void {
        self.props.deinit();
    }

    pub fn addProp(self: *Object, value: PropValue) void {
        self.props.append(.{ .name = undefined, .value = value }) catch unreachable;
    }

    pub fn removeLinkPropsWithId(self: *Object, id: u8) void {
        var delete_index: usize = std.math.maxInt(usize);
        for (self.props.items) |prop, i| {
            switch (prop.value) {
                .link => |linked_id| {
                    if (linked_id == id) {
                        delete_index = i;
                        break;
                    }
                },
                else => {},
            }
        }

        if (delete_index < std.math.maxInt(usize)) {
            _ = self.props.orderedRemove(delete_index);
        }
    }
};

pub const Animation = struct {
    tile: u8,
    rate: u16 = 500,
    tiles: upaya.FixedList(u8, 10),

    pub fn init(tile: u8) Animation {
        var anim = Animation{ .tile = tile, .tiles = upaya.FixedList(u8, 10).init() };
        anim.toggleSelected(tile);
        return anim;
    }

    pub fn toggleSelected(self: *Animation, index: u8) void {
        if (self.tiles.indexOf(index)) |slice_index| {
            _ = self.tiles.swapRemove(slice_index);
        } else {
            self.tiles.append(index);
        }
    }
};
