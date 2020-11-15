const std = @import("std");
const upaya = @import("upaya");

const Writer = std.fs.File.Writer;
const Reader = std.fs.File.Reader;
const AppState = @import("app_state.zig").AppState;

const data = @import("map.zig");
const Map = data.Map;
const RuleSet = data.RuleSet;
const Rule = data.Rule;
const RuleTile = data.RuleTile;
const Tag = data.Tag;
const TileDefinitions = data.TileDefinitions;
const Object = data.Object;
const Animation = data.Animation;

pub fn save(map: Map, file: []const u8) !void {
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();

    const out = handle.writer();
    try out.writeIntLittle(usize, map.w);
    try out.writeIntLittle(usize, map.h);
    try out.writeIntLittle(usize, map.tile_size);
    try out.writeIntLittle(usize, map.tile_spacing);

    try out.writeIntLittle(usize, map.image.len);
    try out.writeAll(map.image);

    const data_bytes = std.mem.sliceAsBytes(map.data);
    try out.writeIntLittle(usize, data_bytes.len);
    try out.writeAll(data_bytes);

    // RuleSet
    try writeRuleSet(out, map.ruleset);

    // groups
    try out.writeIntLittle(usize, map.ruleset_groups.count());
    var iter = map.ruleset_groups.iterator();
    while (iter.next()) |entry| {
        try out.writeIntLittle(u8, entry.key);
        try writeFixedSliceZ(out, entry.value);
    }

    // pre RuleSets
    try out.writeIntLittle(usize, map.pre_rulesets.items.len);
    for (map.pre_rulesets.items) |ruleset| {
        try writeRuleSet(out, ruleset);
    }

    // tags
    try out.writeIntLittle(usize, map.tags.items.len);
    for (map.tags.items) |tag| {
        try writeFixedSliceZ(out, &tag.name);

        try out.writeIntLittle(usize, tag.tiles.len);
        for (tag.tiles.items) |tile, i| {
            if (i == tag.tiles.len) break;
            try out.writeIntLittle(u8, tile);
        }
    }

    // tile definitions
    inline for (@typeInfo(TileDefinitions).Struct.fields) |field| {
        var list = @field(map.tile_definitions, field.name);
        try out.writeIntLittle(usize, list.len);
        for (list.items) |tile, i| {
            if (i == list.len) break;
            try out.writeIntLittle(u8, tile);
        }
    }

    // objects
    try out.writeIntLittle(usize, map.objects.items.len);
    for (map.objects.items) |obj| {
        try out.writeIntLittle(u8, obj.id);
        try writeFixedSliceZ(out, &obj.name);
        try out.writeIntLittle(usize, obj.x);
        try out.writeIntLittle(usize, obj.y);

        try out.writeIntLittle(usize, obj.props.items.len);
        for (obj.props.items) |prop| {
            try writeFixedSliceZ(out, &prop.name);
            try writeUnion(out, prop.value);
        }
    }

    // animations
    try out.writeIntLittle(usize, map.animations.items.len);
    for (map.animations.items) |anim| {
        try out.writeIntLittle(u8, anim.tile);
        try out.writeIntLittle(u16, anim.rate);

        try out.writeIntLittle(usize, anim.tiles.len);
        for (anim.tiles.items) |tile, i| {
            if (i == anim.tiles.len) break;
            try out.writeIntLittle(u8, tile);
        }
    }
}

fn writeRuleSet(out: Writer, ruleset: RuleSet) !void {
    try out.writeIntLittle(u64, ruleset.seed);
    try out.writeIntLittle(u8, ruleset.repeat);

    try out.writeIntLittle(usize, ruleset.rules.items.len);
    for (ruleset.rules.items) |rule| {
        try writeFixedSliceZ(out, &rule.name);
        try out.writeIntLittle(u8, rule.group);

        for (rule.rule_tiles) |rule_tile| {
            try out.writeIntLittle(usize, rule_tile.tile);
            try out.writeIntLittle(u8, @enumToInt(rule_tile.state));
        }

        try out.writeIntLittle(u8, rule.chance);

        try out.writeIntLittle(usize, rule.result_tiles.len);
        for (rule.result_tiles.items) |result_tiles, i| {
            if (i == rule.result_tiles.len) break;
            try out.writeIntLittle(u8, result_tiles);
        }
    }
}

pub fn load(file: []const u8) !Map {
    var handle = try std.fs.cwd().openFile(file, .{});
    defer handle.close();

    var map = Map{
        .data = undefined,
        .ruleset = RuleSet.init(),
        .ruleset_groups = std.AutoHashMap(u8, []const u8).init(upaya.mem.allocator),
        .pre_rulesets = std.ArrayList(RuleSet).init(upaya.mem.allocator),
        .tags = std.ArrayList(Tag).init(upaya.mem.allocator),
        .tile_definitions = .{},
        .objects = std.ArrayList(Object).init(upaya.mem.allocator),
        .animations = std.ArrayList(Animation).init(upaya.mem.allocator),
    };

    const in = handle.reader();
    map.w = try in.readIntLittle(usize);
    map.h = try in.readIntLittle(usize);
    map.tile_size = try in.readIntLittle(usize);
    map.tile_spacing = try in.readIntLittle(usize);

    var image_len = try in.readIntLittle(usize);
    if (image_len > 0) {
        const buffer = try upaya.mem.allocator.alloc(u8, image_len);
        _ = try in.readAll(buffer);
        map.image = buffer;
    }

    // map data
    const data_len = try in.readIntLittle(usize);
    map.data = try upaya.mem.allocator.alloc(u8, data_len);
    _ = try in.readAll(map.data);

    // RuleSet
    try readIntoRuleSet(in, &map.ruleset);

    // grouops
    const group_len = try in.readIntLittle(usize);
    var i: usize = 0;
    while (i < group_len) : (i += 1) {
        const key = try in.readIntLittle(u8);
        const len = try in.readIntLittle(usize);
        std.debug.assert(len != 0);

        const value = try upaya.mem.allocator.alloc(u8, len);
        _ = try in.readAll(value);
        map.ruleset_groups.put(key, value) catch unreachable;
    }

    // pre RuleSets
    const pre_ruleset_count = try in.readIntLittle(usize);
    _ = try map.pre_rulesets.ensureCapacity(pre_ruleset_count);
    i = 0;
    while (i < pre_ruleset_count) : (i += 1) {
        var ruleset = RuleSet.init();
        try readIntoRuleSet(in, &ruleset);
        _ = try map.pre_rulesets.append(ruleset);
    }

    // tags
    const tag_cnt = try in.readIntLittle(usize);
    _ = try map.tags.ensureCapacity(tag_cnt);

    i = 0;
    while (i < tag_cnt) : (i += 1) {
        var tag = Tag.init();

        try readFixedSliceZ(in, &tag.name);

        var tile_len = try in.readIntLittle(usize);
        while (tile_len > 0) : (tile_len -= 1) {
            tag.tiles.append(try in.readIntLittle(u8));
        }

        try map.tags.append(tag);
    }

    // tile definitions
    inline for (@typeInfo(TileDefinitions).Struct.fields) |field| {
        var list = &@field(map.tile_definitions, field.name);

        var tile_len = try in.readIntLittle(usize);
        while (tile_len > 0) : (tile_len -= 1) {
            list.append(try in.readIntLittle(u8));
        }
    }

    // objects
    const obj_cnt = try in.readIntLittle(usize);
    _ = try map.objects.ensureCapacity(obj_cnt);

    i = 0;
    while (i < obj_cnt) : (i += 1) {
        var obj = Object.init(try in.readIntLittle(u8));

        try readFixedSliceZ(in, &obj.name);
        obj.x = try in.readIntLittle(usize);
        obj.y = try in.readIntLittle(usize);

        var props_len = try in.readIntLittle(usize);
        try obj.props.ensureCapacity(props_len);
        while (props_len > 0) : (props_len -= 1) {
            var prop = Object.Prop.init();
            try readFixedSliceZ(in, &prop.name);
            try readUnionInto(in, &prop.value);
            obj.props.appendAssumeCapacity(prop);
        }

        map.objects.appendAssumeCapacity(obj);
    }

    // animations
    const anim_cnt = try in.readIntLittle(usize);
    _ = try map.animations.ensureCapacity(anim_cnt);

    i = 0;
    while (i < anim_cnt) : (i += 1) {
        var anim = Animation.init(try in.readIntLittle(u8));
        anim.rate = try in.readIntLittle(u16);

        var tile_len = try in.readIntLittle(usize);
        while (tile_len > 0) : (tile_len -= 1) {
            anim.tiles.append(try in.readIntLittle(u8));
        }

        try map.animations.append(anim);
    }

    return map;
}

fn readIntoRuleSet(in: Reader, ruleset: *RuleSet) !void {
    ruleset.seed = try in.readIntLittle(u64);
    ruleset.repeat = try in.readIntLittle(u8);
    const rule_count = try in.readIntLittle(usize);

    _ = try ruleset.rules.ensureCapacity(rule_count);
    var i: usize = 0;
    while (i < rule_count) : (i += 1) {
        try ruleset.rules.append(try readRule(in));
    }
}

fn readRule(in: Reader) !Rule {
    var rule = Rule.init();

    try readFixedSliceZ(in, &rule.name);
    rule.group = try in.readIntLittle(u8);

    for (rule.rule_tiles) |*rule_tile| {
        rule_tile.tile = try in.readIntLittle(usize);
        rule_tile.state = @intToEnum(RuleTile.RuleState, @intCast(u4, try in.readIntLittle(u8)));
    }

    rule.chance = try in.readIntLittle(u8);

    const result_tiles_len = try in.readIntLittle(usize);
    if (result_tiles_len > 100) return error.WTF;
    var i: usize = 0;
    while (i < result_tiles_len) : (i += 1) {
        rule.result_tiles.append(try in.readIntLittle(u8));
    }

    return rule;
}

// generic write helpers
fn writeFixedSliceZ(out: Writer, slice: []const u8) !void {
    const sentinel_index = std.mem.indexOfScalar(u8, slice, 0) orelse slice.len;
    const txt = slice[0..sentinel_index];
    try out.writeIntLittle(usize, txt.len);

    if (txt.len > 0) {
        try out.writeAll(txt);
    }
}

fn writeUnion(out: Writer, value: anytype) !void {
    const info = @typeInfo(@TypeOf(value)).Union;
    if (info.tag_type) |TagType| {
        const active_tag = std.meta.activeTag(value);
        try writeValue(out, active_tag);

        inline for (std.meta.fields(TagType)) |field_info| {
            if (field_info.value == @enumToInt(active_tag)) {
                const name = field_info.name;
                try writeValue(out, @field(value, name));
            }
        }
    }
}

fn writeValue(out: Writer, value: anytype) !void {
    const T = comptime @TypeOf(value);

    if (comptime std.meta.trait.isIndexable(T)) {
        for (value) |v|
            try writeValue(out, v);
        return;
    }

    switch (@typeInfo(T)) {
        .Int => try out.writeIntLittle(T, value),
        .Float => try out.writeIntLittle(i32, @bitCast(i32, value)), // zig pre-0.7 try out.writeIntLittle(T, value)
        .Enum => try writeValue(out, @enumToInt(value)),
        else => unreachable,
    }
}

// generic read helpers
fn readUnionInto(in: Reader, ptr: anytype) !void {
    const C = comptime std.meta.Child(@TypeOf(ptr));
    const info = @typeInfo(C).Union;

    if (info.tag_type) |TagType| {
        // this is a technically a u2 but we read it as a u8 because there is no bit packing in this reader/writer
        const tag = try in.readIntLittle(u8);

        inline for (std.meta.fields(TagType)) |field_info| {
            if (field_info.value == tag) {
                const name = field_info.name;
                ptr.* = @unionInit(C, name, undefined);
                try readValueInto(in, &@field(ptr, name));
            }
        }
    }
}

fn readValueInto(in: Reader, ptr: anytype) !void {
    const T = @TypeOf(ptr);
    comptime std.debug.assert(std.meta.trait.is(.Pointer)(T));

    if (comptime std.meta.trait.isSlice(T) or comptime std.meta.trait.isPtrTo(.Array)(T)) {
        for (ptr) |*v|
            try readValueInto(in, v);
        return;
    }

    comptime std.debug.assert(std.meta.trait.isSingleItemPtr(T));

    const C = comptime std.meta.Child(T);
    const child_ti = @typeInfo(C);

    switch (child_ti) {
        .Int => ptr.* = try in.readIntLittle(C),
        .Float => ptr.* = @bitCast(f32, try in.readIntLittle(i32)), // zig pre-0.7 ptr.* = try in.readIntLittle(C)
        else => unreachable,
    }
}

// generic read helpers
fn readFixedSliceZ(in: Reader, dst: []u8) !void {
    const len = try in.readIntLittle(usize);
    if (len > 0) {
        const buffer = try upaya.mem.tmp_allocator.alloc(u8, len);
        _ = try in.readAll(buffer);
        std.mem.copy(u8, dst, buffer);
    }
}

// export
pub fn exportJson(map: Map, map_data: []u8, file: []const u8) !void {
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();
    const out_stream = handle.writer();

    var jw = std.json.writeStream(out_stream, 10);
    {
        try jw.beginObject();
        defer jw.endObject() catch unreachable;

        try jw.objectField("w");
        try jw.emitNumber(map.w);

        try jw.objectField("h");
        try jw.emitNumber(map.h);

        try jw.objectField("tile_size");
        try jw.emitNumber(map.tile_size);

        try jw.objectField("tile_spacing");
        try jw.emitNumber(map.tile_spacing);

        try jw.objectField("image");
        try jw.emitString(map.image);

        // tags
        try jw.objectField("tags");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (map.tags.items) |tag| {
                try jw.arrayElem();
                try jw.beginObject();

                const sentinel_index = std.mem.indexOfScalar(u8, &tag.name, 0) orelse tag.name.len;
                const name = tag.name[0..sentinel_index];
                try jw.objectField("name");
                try jw.emitString(name);

                try jw.objectField("tiles");
                try jw.beginArray();
                for (tag.tiles.items) |tile, i| {
                    if (i == tag.tiles.len) break;
                    try jw.arrayElem();
                    try jw.emitNumber(tile);
                }
                try jw.endArray();

                try jw.endObject();
            }
        }

        // tile definitions
        try jw.objectField("tile_definitions");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            inline for (@typeInfo(TileDefinitions).Struct.fields) |field| {
                try jw.arrayElem();
                try jw.beginObject();

                try jw.objectField(field.name);

                var list = @field(map.tile_definitions, field.name);
                try jw.beginArray();
                for (list.items) |tile, i| {
                    if (i == list.len) break;
                    try jw.arrayElem();
                    try jw.emitNumber(tile);
                }
                try jw.endArray();

                try jw.endObject();
            }
        }

        // objects
        try jw.objectField("objects");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (map.objects.items) |obj| {
                try jw.arrayElem();
                try jw.beginObject();

                try jw.objectField("id");
                try jw.emitNumber(obj.id);

                const sentinel_index = std.mem.indexOfScalar(u8, &obj.name, 0) orelse obj.name.len;
                try jw.objectField("name");
                try jw.emitString(obj.name[0..sentinel_index]);

                try jw.objectField("x");
                try jw.emitNumber(obj.x);

                try jw.objectField("y");
                try jw.emitNumber(obj.y);

                for (obj.props.items) |prop| {
                    const prop_sentinel_index = std.mem.indexOfScalar(u8, &prop.name, 0) orelse prop.name.len;
                    try jw.objectField(prop.name[0..prop_sentinel_index]);

                    switch (prop.value) {
                        .string => |str| {
                            const prop_value_sentinel_index = std.mem.indexOfScalar(u8, &str, 0) orelse str.len;
                            try jw.emitString(str[0..prop_value_sentinel_index]);
                        },
                        .int => |int| try jw.emitNumber(int),
                        .float => |float| try jw.emitNumber(float),
                        .link => |link| try jw.emitNumber(link),
                    }
                }

                try jw.endObject();
            }
        }

        // animations
        try jw.objectField("animations");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (map.animations.items) |anim| {
                try jw.arrayElem();
                try jw.beginObject();

                try jw.objectField("tile");
                try jw.emitNumber(anim.tile);

                try jw.objectField("rate");
                try jw.emitNumber(anim.rate);

                try jw.objectField("tiles");
                try jw.beginArray();
                for (anim.tiles.items) |tile, i| {
                    if (i == anim.tiles.len) break;
                    try jw.arrayElem();
                    try jw.emitNumber(tile);
                }
                try jw.endArray();

                try jw.endObject();
            }
        }

        // map data
        try jw.objectField("data");
        try jw.beginArray();
        for (map_data) |d| {
            try jw.arrayElem();
            try jw.emitNumber(d);
        }
        try jw.endArray();
    }
}

pub fn exportTiled(state: *AppState, file: []const u8) !void {
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();
    const out_stream = handle.writer();

    var jw = std.json.writeStream(out_stream, 10);
    {
        try jw.beginObject();
        defer jw.endObject() catch unreachable;

        try jw.objectField("width");
        try jw.emitNumber(state.map.w);

        try jw.objectField("height");
        try jw.emitNumber(state.map.h);

        try jw.objectField("tilewidth");
        try jw.emitNumber(state.map.tile_size);

        try jw.objectField("tileheight");
        try jw.emitNumber(state.map.tile_size);

        try jw.objectField("infinite");
        try jw.emitBool(false);

        try jw.objectField("version");
        try jw.emitNumber(1.2);

        try jw.objectField("tiledversion");
        try jw.emitString("1.3.2");

        try jw.objectField("orientation");
        try jw.emitString("orthogonal");

        try jw.objectField("renderorder");
        try jw.emitString("right-down");

        try jw.objectField("type");
        try jw.emitString("map");

        try jw.objectField("nextlayerid");
        try jw.emitNumber(2);

        try jw.objectField("nextobjectid");
        try jw.emitNumber(1);

        // tileset
        try jw.objectField("tilesets");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            try jw.arrayElem();
            try jw.beginObject();

            try jw.objectField("image");
            try jw.emitString(state.map.image);

            try jw.objectField("margin");
            try jw.emitNumber(state.map.tile_spacing);

            try jw.objectField("spacing");
            try jw.emitNumber(state.map.tile_spacing);

            try jw.objectField("imagewidth");
            try jw.emitNumber(state.texture.width);

            try jw.objectField("imageheight");
            try jw.emitNumber(state.texture.width);

            try jw.objectField("tilewidth");
            try jw.emitNumber(state.map.tile_size);

            try jw.objectField("tileheight");
            try jw.emitNumber(state.map.tile_size);

            try jw.objectField("columns");
            try jw.emitNumber(state.tilesPerCol());

            try jw.objectField("firstgid");
            try jw.emitNumber(1);

            try jw.objectField("tiles");
            try jw.beginArray();
            try jw.endArray();

            try jw.endObject();
        }

        // layer
        try jw.objectField("layers");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            try jw.arrayElem();
            try jw.beginObject();

            // map data
            try jw.objectField("data");
            try jw.beginArray();
            for (state.final_map_data) |d| {
                try jw.arrayElem();
                try jw.emitNumber(d);
            }
            try jw.endArray();

            try jw.objectField("width");
            try jw.emitNumber(state.map.w);

            try jw.objectField("height");
            try jw.emitNumber(state.map.h);

            try jw.objectField("id");
            try jw.emitNumber(1);

            try jw.objectField("name");
            try jw.emitString("main");

            try jw.objectField("type");
            try jw.emitString("tilelayer");

            try jw.objectField("visible");
            try jw.emitBool(true);

            try jw.objectField("opacity");
            try jw.emitNumber(1);

            try jw.objectField("x");
            try jw.emitNumber(0);

            try jw.objectField("y");
            try jw.emitNumber(0);

            try jw.endObject();
        }
    }
}
