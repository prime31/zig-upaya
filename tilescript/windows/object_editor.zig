const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
const imgui = @import("imgui");

var buffer: [5]u8 = undefined;
var inspected_object_index: ?usize = null;

pub fn draw(state: *ts.AppState) void {
    if (state.prefs.windows.object_editor) {
        imgui.igPushStyleVarVec2(imgui.ImGuiStyleVar_WindowMinSize, imgui.ImVec2{ .x = 200, .y = 100 });
        defer imgui.igPopStyleVar(1);

        _ = imgui.igBegin("Object Editor", &state.prefs.windows.object_editor, imgui.ImGuiWindowFlags_None);
        defer imgui.igEnd();

        if (imgui.igBeginChildEx("##obj-editor-child", imgui.igGetItemID(), imgui.ImVec2{ .y = -imgui.igGetFrameHeightWithSpacing() }, false, imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndChild();

            if (inspected_object_index) |obj_index| {
                var obj = &state.map.objects.items[obj_index];

                imgui.igPushItemWidth(imgui.igGetWindowContentRegionWidth());
                if (imgui.ogInputText("##name", &obj.name, obj.name.len)) {}
                imgui.igPopItemWidth();

                _=  imgui.ogDrag(usize, "Tile X", &obj.x, 0.5, 0, state.map.w - 1);
                _=  imgui.ogDrag(usize, "Tile Y", &obj.y, 0.5, 0, state.map.h - 1);

                 imgui.igSeparator();

                // custom properties
                var delete_index: usize = std.math.maxInt(usize);
                for (obj.props.items) |*prop, i| {
                    imgui.igPushIDPtr(prop);

                    imgui.igPushItemWidth(imgui.igGetWindowContentRegionWidth() / 2 - 15);
                    if (imgui.ogInputText("##key", &prop.name, prop.name.len)) {}
                    imgui.igSameLine(0, 5);

                    switch (prop.value) {
                        .string => |*str| {
                            _ = imgui.ogInputText("##value", str, str.len);
                        },
                        .float => |*flt| {
                            _=  imgui.ogDragSigned(f32, "##flt", flt, 1, std.math.minInt(i32), std.math.maxInt(i32));
                        },
                        .int => |*int| {
                            _=  imgui.ogDragSigned(i32, "##int", int, 1, std.math.minInt(i32), std.math.maxInt(i32));
                        },
                        .link => |linked_id| {
                            imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
                            imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
                            _ = std.fmt.bufPrint(&buffer, "${}", .{linked_id}) catch unreachable;
                            _ = imgui.ogInputText("##value", &buffer, buffer.len);
                            imgui.igPopItemFlag();
                            imgui.igPopStyleVar(1);
                        },
                    }

                    imgui.igSameLine(0, 5);
                    imgui.igPopItemWidth();

                    imgui.igSameLine(0, 5);
                    if (imgui.ogButton(imgui.icons.trash)) {
                        delete_index = i;
                    }

                    imgui.igPopID();
                }

                if (delete_index < std.math.maxInt(usize)) {
                    _ = obj.props.orderedRemove(delete_index);
                }
            }
        }

        if (inspected_object_index == null) {
            imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
            imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
        }

        if (imgui.igButton("Add Property", imgui.ImVec2{})) {
            imgui.igOpenPopup("##add-property");
        }

        if (inspected_object_index == null) {
            imgui.igPopItemFlag();
            imgui.igPopStyleVar(1);
        }

        imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##add-property", imgui.ImGuiWindowFlags_None)) {
            addPropertyPopup(state);
            imgui.igEndPopup();
        }
    }
}

fn addPropertyPopup(state: *ts.AppState) void {
    imgui.igText("Property Type");
    if (imgui.igButton("string", imgui.ImVec2{ .x = 100 })) {
        state.map.objects.items[inspected_object_index.?].addProp(.{ .string = undefined });
        imgui.igCloseCurrentPopup();
    }
    if (imgui.igButton("float", imgui.ImVec2{ .x = 100 })) {
        state.map.objects.items[inspected_object_index.?].addProp(.{ .float = undefined });
        imgui.igCloseCurrentPopup();
    }
    if (imgui.igButton("int", imgui.ImVec2{ .x = 100 })) {
        state.map.objects.items[inspected_object_index.?].addProp(.{ .int = undefined });
        imgui.igCloseCurrentPopup();
    }
}

pub fn setSelectedObject(index: ?usize) void {
    inspected_object_index = index;
}
