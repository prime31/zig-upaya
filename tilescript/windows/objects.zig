const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
usingnamespace @import("imgui");

const object_editor = @import("object_editor.zig");

var filter_buffer: [25]u8 = undefined;
var filter = false;
var selected_index: usize = std.math.maxInt(usize);

pub fn draw(state: *ts.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 100 });
    defer igPopStyleVar(1);

    if (state.prefs.windows.objects) {
        _ = igBegin("Objects", &state.prefs.windows.objects, ImGuiWindowFlags_None);
        defer igEnd();

        if (igBeginChildEx("##obj-child", igGetItemID(), .{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            igPushItemWidth(igGetWindowContentRegionWidth());
            if (ogInputText("##obj-filter", &filter_buffer, filter_buffer.len)) {
                const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                filter = null_index > 0;
            }
            igPopItemWidth();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.objects.items) |*obj, i| {
                if (filter) {
                    const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                    if (std.mem.indexOf(u8, &obj.name, filter_buffer[0..null_index]) == null) {
                        continue;
                    }
                }
                igPushIDInt(@intCast(c_int, i));

                if (igSelectableBool(&obj.name, selected_index == i, ImGuiSelectableFlags_None, .{.x = igGetWindowContentRegionWidth() - 24})) {
                    selected_index = i;
                    object_editor.setSelectedObject(selected_index);
                    state.prefs.windows.object_editor = true;
                }

                igSameLine(igGetWindowContentRegionWidth() - 20, 0);
                igSetCursorPosY(igGetCursorPosY() - 3);
                if (ogButton(icons.trash)) {
                    delete_index = i;
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                if (delete_index == selected_index) {
                    selected_index = std.math.maxInt(usize);
                    object_editor.setSelectedObject(null);
                } else if (delete_index < selected_index and selected_index != std.math.maxInt(usize)) {
                    selected_index -= 1;
                    object_editor.setSelectedObject(selected_index);
                }

                // cleanup any links to this object
                var deleted_id = state.map.objects.items[delete_index].id;
                for (state.map.objects.items) |*obj| {
                    obj.removeLinkPropsWithId(deleted_id);
                }
                _ = state.map.objects.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Object", .{})) {
            state.map.addObject();
            object_editor.setSelectedObject(state.map.objects.items.len - 1);
            state.prefs.windows.object_editor = true;
        }
    }
}

pub fn setSelectedObject(index: usize) void {
    selected_index = index;
}