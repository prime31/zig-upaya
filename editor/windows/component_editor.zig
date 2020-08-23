const std = @import("std");
const upaya = @import("upaya");
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

var name_buf: [25]u8 = undefined;

pub fn draw(state: *editor.AppState) void {
    igSetNextWindowSize(.{ .x = 500, .y = -1 }, ImGuiCond_Always);
    var open: bool = true;
    if (igBeginPopupModal("Component Editor", &open, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        igColumns(2, "id", true);
        igSetColumnWidth(0, 150);

        igPushItemWidth(-1);
        if (igListBoxHeaderVec2("", .{})) {
            defer igListBoxFooter();

            if (igSelectableBool("Transform", false, ImGuiSelectableFlags_DontClosePopups, .{})) {}
            if (igSelectableBool("BoxCollider", false, ImGuiSelectableFlags_DontClosePopups, .{})) {}
        }
        igPopItemWidth();

        igNextColumn();
        drawDetailsPane(state);

        igColumns(1, "id", false);
        if (ogButton("Add Component")) {
            igOpenPopup("##new-component");
            std.mem.copy(u8, &name_buf, "NewComponent");
        }

        igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("##new-component", ImGuiWindowFlags_None)) {
            _ = ogInputText("##name", &name_buf, name_buf.len);

            if (igButton("Create Component", .{ .x = -1, .y = 0 })) {
                igCloseCurrentPopup();
                const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
                std.debug.print("new comp name: {}\n", .{name_buf[0..label_sentinel_index]});
            }

            igEndPopup();
        }
    }
}

fn drawDetailsPane(state: *editor.AppState) void {
    if (igButton("Add Field", ImVec2{})) {
        igOpenPopup("##add-field");
    }

    igPushItemWidth(igGetColumnWidth(1) / 2 - 20);
    _ = ogInputText("##key", &name_buf, name_buf.len);
    igSameLine(0, 5);

    _ = ogInputText("##value", &name_buf, name_buf.len);
    igSameLine(0, 5);

    igPopItemWidth();
    if (ogButton(icons.trash)) {}

    addFieldPopup(state);
}

fn addFieldPopup(state: *editor.AppState) void {
    igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    if (igBeginPopup("##add-field", ImGuiWindowFlags_None)) {
        igText("Field Type");
        if (igButton("bool", .{ .x = 100 })) {
            igCloseCurrentPopup();
        }
        if (igButton("string", .{ .x = 100 })) {
            igCloseCurrentPopup();
        }
        if (igButton("float", .{ .x = 100 })) {
            igCloseCurrentPopup();
        }
        if (igButton("int", .{ .x = 100 })) {
            igCloseCurrentPopup();
        }
        igEndPopup();
    }
}
