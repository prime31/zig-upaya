const std = @import("std");
const upaya = @import("upaya");
const editor = @import("../editor.zig");
const imgui = @import("imgui");

var name_buf: [25]u8 = undefined;

pub fn draw(state: *editor.AppState) void {
    imgui.igSetNextWindowSize(.{ .x = 500, .y = -1 },  imgui.ImGuiCond_Always);
    var open: bool = true;
    if (imgui.igBeginPopupModal("Component Editor", &open, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndPopup();

        imgui.igColumns(2, "id", true);
        imgui.igSetColumnWidth(0, 150);

        imgui.igPushItemWidth(-1);
        if (imgui.igListBoxHeaderVec2("", .{})) {
            defer imgui.igListBoxFooter();

            if (imgui.igSelectableBool("Transform", false, imgui.ImGuiSelectableFlags_DontClosePopups, .{})) {}
            if (imgui.igSelectableBool("BoxCollider", false, imgui.ImGuiSelectableFlags_DontClosePopups, .{})) {}
        }
        imgui.igPopItemWidth();

        imgui.igNextColumn();
        drawDetailsPane(state);

        imgui.igColumns(1, "id", false);
        if (imgui.ogButton("Add Component")) {
            imgui.igOpenPopup("##new-component");
            std.mem.copy(u8, &name_buf, "NewComponent");
        }

        imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##new-component", imgui.ImGuiWindowFlags_None)) {
            _ = imgui.ogInputText("##name", &name_buf, name_buf.len);

            if (imgui.igButton("Create Component", .{ .x = -1, .y = 0 })) {
                imgui.igCloseCurrentPopup();
                const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
                std.debug.print("new comp name: {s}\n", .{name_buf[0..label_sentinel_index]});
            }

            imgui.igEndPopup();
        }
    }
}

fn drawDetailsPane(state: *editor.AppState) void {
    if (imgui.igButton("Add Field", imgui.ImVec2{})) {
        imgui.igOpenPopup("##add-field");
    }

    imgui.igPushItemWidth(imgui.igGetColumnWidth(1) / 2 - 20);
    _ = imgui.ogInputText("##key", &name_buf, name_buf.len);
    imgui.igSameLine(0, 5);

    _ = imgui.ogInputText("##value", &name_buf, name_buf.len);
    imgui.igSameLine(0, 5);

    imgui.igPopItemWidth();
    if (imgui.ogButton(imgui.icons.trash)) {}

    addFieldPopup(state);
}

fn addFieldPopup(state: *editor.AppState) void {
    _ = state;
    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("##add-field", imgui.ImGuiWindowFlags_None)) {
        imgui.igText("Field Type");
        if (imgui.igButton("bool", .{ .x = 100 })) {
            imgui.igCloseCurrentPopup();
        }
        if (imgui.igButton("string", .{ .x = 100 })) {
            imgui.igCloseCurrentPopup();
        }
        if (imgui.igButton("float", .{ .x = 100 })) {
            imgui.igCloseCurrentPopup();
        }
        if (imgui.igButton("int", .{ .x = 100 })) {
            imgui.igCloseCurrentPopup();
        }
        imgui.igEndPopup();
    }
}
