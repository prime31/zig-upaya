const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
const imgui = @import("imgui");

const object_editor = @import("object_editor.zig");

var filter_buffer: [25]u8 = undefined;
var filter = false;
var selected_index: usize = std.math.maxInt(usize);

pub fn draw(state: *ts.AppState) void {
    imgui.igPushStyleVarVec2(imgui.ImGuiStyleVar_WindowMinSize, imgui.ImVec2{ .x = 200, .y = 100 });
    defer imgui.igPopStyleVar(1);

    if (state.prefs.windows.objects) {
        _ = imgui.igBegin("Objects", &state.prefs.windows.objects, imgui.ImGuiWindowFlags_None);
        defer imgui.igEnd();

        if (imgui.igBeginChildEx("##obj-child", imgui.igGetItemID(), .{ .y = -imgui.igGetFrameHeightWithSpacing() }, false, imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndChild();

            imgui.igPushItemWidth(imgui.igGetWindowContentRegionWidth());
            if (imgui.ogInputText("##obj-filter", &filter_buffer, filter_buffer.len)) {
                const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                filter = null_index > 0;
            }
            imgui.igPopItemWidth();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.objects.items) |*obj, i| {
                if (filter) {
                    const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                    if (std.mem.indexOf(u8, &obj.name, filter_buffer[0..null_index]) == null) {
                        continue;
                    }
                }
                imgui.igPushIDInt(@intCast(c_int, i));

                if (imgui.igSelectableBool(&obj.name, selected_index == i, imgui.ImGuiSelectableFlags_None, .{ .x = imgui.igGetWindowContentRegionWidth() - 24 })) {
                    selected_index = i;
                    object_editor.setSelectedObject(selected_index);
                    state.prefs.windows.object_editor = true;
                }

                imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 20, 0);
                imgui.igSetCursorPosY(imgui.igGetCursorPosY() - 3);
                if (imgui.ogButton(imgui.icons.trash)) {
                    delete_index = i;
                }

                imgui.igPopID();
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

        if (imgui.igButton("Add Object", .{})) {
            state.map.addObject();
            object_editor.setSelectedObject(state.map.objects.items.len - 1);
            state.prefs.windows.object_editor = true;
        }
    }
}

pub fn setSelectedObject(index: usize) void {
    selected_index = index;
}
