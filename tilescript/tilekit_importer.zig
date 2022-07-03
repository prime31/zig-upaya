const std = @import("std");
const upaya = @import("upaya");
const tilescript = @import("tilescript.zig");

pub fn import(file: []const u8) !tilescript.Map {
    var bytes = try std.fs.cwd().readFileAlloc(upaya.mem.allocator, file, std.math.maxInt(usize));
    var tokens = std.json.TokenStream.init(bytes);

    // TODO: why does this poop itself when using the real allocator?
    @setEvalBranchQuota(10000);

    const options = std.json.ParseOptions{ .allocator = upaya.mem.tmp_allocator };
    var res = try std.json.parse(TileKitMap, &tokens, options);
    defer std.json.parseFree(TileKitMap, res, options);

    var map = tilescript.Map.init(res.output_map.tile_w, res.output_map.tile_spacing);
    map.w = res.input_map.w;
    map.h = res.input_map.h;
    map.image = try upaya.mem.allocator.dupe(u8, res.output_map.image_filename);

    upaya.mem.allocator.free(map.data);
    map.data = try upaya.mem.allocator.alloc(u8, map.w * map.h);
    std.mem.copy(u8, map.data, res.input_map.data);

    map.ruleset.seed = res.final_ruleset.seed;
    map.ruleset.repeat = res.final_ruleset.repeat;
    for (res.final_ruleset.rules) |rule| {
        map.ruleset.rules.append(rule.toAyaRule()) catch {};
    }

    for (res.rulesets) |ruleset| {
        map.addPreRuleSet();
        var pre_ruleset = &map.pre_rulesets.items[map.pre_rulesets.items.len - 1];
        pre_ruleset.seed = ruleset.seed;
        pre_ruleset.repeat = ruleset.repeat;

        for (ruleset.rules) |rule| {
            try pre_ruleset.rules.append(rule.toAyaRule());
        }
    }

    for (res.output_map.animations) |anim| {
        map.addAnimation(@intCast(u8, anim.idx - 1));
        var aya_anim = &map.animations.items[map.animations.items.len - 1];
        aya_anim.rate = @intCast(u16, anim.rate);

        for (anim.frames) |frame| {
            // dont double-add the root frame
            if (frame != anim.idx) {
                aya_anim.toggleSelected(frame - 1);
            }
        }
    }

    for (res.objects) |obj, i| {
        map.addObject();
        var aya_obj = &map.objects.items[map.objects.items.len - 1];
        aya_obj.id = @intCast(u8, i);
        std.mem.copy(u8, &aya_obj.name, obj.name);
        aya_obj.x = @divTrunc(std.fmt.parseInt(usize, obj.x, 10) catch unreachable, res.output_map.tile_w);
        aya_obj.y = @divTrunc(std.fmt.parseInt(usize, obj.y, 10) catch unreachable, res.output_map.tile_w);
    }

    return map;
}

pub const TileKitMap = struct {
    // TODO: why cant zig compile with these?!?!
    // version: []const u8 = "",
    // tile_w: i32,
    // tile_h: i32,
    brush_idx: usize,
    ruleset_idx: i32,
    input_map: InputMap,
    output_map: OutputMap,
    final_ruleset: RuleSet,
    rulesets: []RuleSet,
    objects: []Object,
    edit_mode: u8,

    pub const InputMap = struct {
        w: usize,
        h: usize,
        data: []u8,
    };

    pub const OutputMap = struct {
        tile_w: usize,
        tile_h: usize,
        tile_spacing: usize,
        image_filename: []const u8 = "",
        animations: []Animation,
        tags: []Tag,
    };

    pub const RuleSet = struct {
        seed: usize,
        repeat: u8,
        rules: []Rule,
    };

    pub const Rule = struct {
        label: []const u8 = "",
        chance: u8,
        offsets: []RuleOffsets,
        results: []u8,

        pub fn toAyaRule(self: @This()) tilescript.data.Rule {
            var rule = tilescript.data.Rule.init();
            std.mem.copy(u8, &rule.name, self.label);
            rule.chance = self.chance;

            for (self.results) |tile| {
                rule.result_tiles.append(tile - 1);
            }

            for (self.offsets) |offset| {
                var rule_tile = rule.get(@intCast(usize, offset.x + 2), @intCast(usize, offset.y + 2));
                if (offset.type == 1) {
                    rule_tile.require(offset.val);
                } else if (offset.type == 2) {
                    rule_tile.negate(offset.val);
                } else {
                    rule_tile.tile = offset.val;
                }
            }

            return rule;
        }
    };

    pub const RuleOffsets = struct {
        x: i32 = 0,
        y: i32 = 0,
        val: usize = 0,
        type: u8 = 0,
    };

    pub const Animation = struct {
        idx: usize = 0,
        rate: usize = 0,
        frames: []u8,
    };

    pub const Object = struct {
        name: []const u8 = "",
        id: []const u8 = "",
        x: []const u8 = "",
        y: []const u8 = "",
        w: []const u8 = "",
        h: []const u8 = "",
        color: []const u8 = "",
        destination: []const u8 = "",
    };

    pub const Tag = struct {
        label: []const u8,
        tiles: []u8,
    };
};
