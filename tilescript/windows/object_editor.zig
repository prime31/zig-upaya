const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
usingnamespace @import("imgui");

var buffer: [5]u8 = undefined;
var inspected_object_index: ?usize = null;

pub fn draw(state: *ts.AppState) void {
    if (state.prefs.windows.object_editor) {
        igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 100 });
        defer igPopStyleVar(1);

        _ = igBegin("Object Editor", &state.prefs.windows.object_editor, ImGuiWindowFlags_None);
        defer igEnd();

        if (igBeginChildEx("##obj-editor-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            if (inspected_object_index) |obj_index| {
                var obj = &state.map.objects.items[obj_index];

                igPushItemWidth(igGetWindowContentRegionWidth());
                if (ogInputText("##name", &obj.name, obj.name.len)) {}
                igPopItemWidth();

                _ = ogDrag(usize, "Tile X", &obj.x, 0.5, 0, state.map.w - 1);
                _ = ogDrag(usize, "Tile Y", &obj.y, 0.5, 0, state.map.h - 1);

                igSeparator();

                // custom properties
                var delete_index: usize = std.math.maxInt(usize);
                for (obj.props.items) |*prop, i| {
                    igPushIDPtr(prop);

                    igPushItemWidth(igGetWindowContentRegionWidth() / 2 - 15);
                    if (ogInputText("##key", &prop.name, prop.name.len)) {}
                    igSameLine(0, 5);

                    switch (prop.value) {
                        .string => |*str| {
                            _ = ogInputText("##value", str, str.len);
                        },
                        .float => |*flt| {
                            _ = ogDragSigned(f32, "##flt", flt, 1, std.math.minInt(i32), std.math.maxInt(i32));
                        },
                        .int => |*int| {
                            _ = ogDragSigned(i32, "##int", int, 1, std.math.minInt(i32), std.math.maxInt(i32));
                        },
                        .link => |linked_id| {
                            igPushItemFlag(ImGuiItemFlags_Disabled, true);
                            igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
                            _ = std.fmt.bufPrint(&buffer, "${}", .{linked_id}) catch unreachable;
                            _ = ogInputText("##value", &buffer, buffer.len);
                            igPopItemFlag();
                            igPopStyleVar(1);
                        },
                    }

                    igSameLine(0, 5);
                    igPopItemWidth();

                    igSameLine(0, 5);
                    if (ogButton(icons.trash)) {
                        delete_index = i;
                    }

                    igPopID();
                }

                if (delete_index < std.math.maxInt(usize)) {
                    _ = obj.props.orderedRemove(delete_index);
                }
            }
        }

        if (inspected_object_index == null) {
            igPushItemFlag(ImGuiItemFlags_Disabled, true);
            igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
        }

        if (igButton("Add Property", ImVec2{})) {
            igOpenPopup("##add-property");
        }

        if (inspected_object_index == null) {
            igPopItemFlag();
            igPopStyleVar(1);
        }

        igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("##add-property", ImGuiWindowFlags_None)) {
            addPropertyPopup(state);
            igEndPopup();
        }
    }
}

fn addPropertyPopup(state: *ts.AppState) void {
    igText("Property Type");
    if (igButton("string", ImVec2{ .x = 100 })) {
        state.map.objects.items[inspected_object_index.?].addProp(.{ .string = undefined });
        igCloseCurrentPopup();
    }
    if (igButton("float", ImVec2{ .x = 100 })) {
        state.map.objects.items[inspected_object_index.?].addProp(.{ .float = undefined });
        igCloseCurrentPopup();
    }
    if (igButton("int", ImVec2{ .x = 100 })) {
        state.map.objects.items[inspected_object_index.?].addProp(.{ .int = undefined });
        igCloseCurrentPopup();
    }
}

pub fn setSelectedObject(index: ?usize) void {
    inspected_object_index = index;
}
