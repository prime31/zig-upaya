const std = @import("std");
const print = std.debug.print;
const upaya = @import("upaya");
const imgui = @import("imgui");

pub var ui_tint: imgui.ImVec4 = colorRgbaVec4(135, 45, 176, 255);

pub var brushes: [14]imgui.ImU32 = undefined;
pub var brush_required: imgui.ImU32 = 0;
pub var brush_negated: imgui.ImU32 = 0;
pub var brush_selected: imgui.ImU32 = 0;
pub var pattern_center: imgui.ImU32 = 0;
pub var rule_result_selected_outline: imgui.ImU32 = 0;
pub var rule_result_selected_fill: imgui.ImU32 = 0;
pub var object: imgui.ImU32 = 0;
pub var object_selected: imgui.ImU32 = 0;
pub var object_drag_link: imgui.ImU32 = 0;
pub var object_link: imgui.ImU32 = 0;

pub var white: imgui.ImU32 = 0;

pub fn init() void {
    setDefaultImGuiStyle();

    brushes = [_]imgui.ImU32{
        colorRgb(189, 63, 110),
        colorRgb(242, 165, 59),
        colorRgb(252, 234, 87),
        colorRgb(103, 223, 84),
        colorRgb(82, 172, 247),
        colorRgb(128, 118, 152),

        colorRgb(237, 127, 166),
        colorRgb(246, 205, 174),
        colorRgb(115, 45, 81),
        colorRgb(58, 131, 85),
        colorRgb(159, 86, 60),
        colorRgb(93, 86, 79),

        colorRgb(193, 194, 198),
        colorRgb(252, 240, 232),
    };
    brush_required = colorRgb(117, 249, 76);
    brush_negated = colorRgb(235, 50, 35);
    brush_selected = colorRgb(82, 172, 247);

    pattern_center = colorRgb(255, 253, 84);
    rule_result_selected_outline = colorRgb(116, 252, 253);
    rule_result_selected_fill = colorRgba(116, 252, 253, 100);

    object = colorRgb(116, 252, 50);
    object_selected = colorRgb(282, 172, 247);
    object_drag_link = colorRgb(255, 0, 0);
    object_link = colorRgb(220, 200, 10);

    white = colorRgb(255, 255, 255);
}

fn setDefaultImGuiStyle() void {
    var style = imgui.igGetStyle();
    style.TabRounding = 2;
    style.FrameRounding = 4;
    style.WindowBorderSize = 1;
    style.WindowRounding = 0;
    style.WindowMenuButtonPosition = imgui.ImGuiDir_None;
    style.Colors[imgui.ImGuiCol_WindowBg] = imgui.ogColorConvertU32ToFloat4(colorRgba(25, 25, 25, 255));
    style.Colors[imgui.ImGuiCol_TextSelectedBg] = imgui.ogColorConvertU32ToFloat4(colorRgba(66, 150, 250, 187));

    setTintColor(ui_tint);
}

pub fn setTintColor(color: imgui.ImVec4) void {
    var colors = &imgui.igGetStyle().Colors;
    colors[imgui.ImGuiCol_FrameBg] = hsvShiftColor(color, 0, 0, -0.2);
    colors[imgui.ImGuiCol_Border] = hsvShiftColor(color, 0, 0, -0.2);

    const header = hsvShiftColor(color, 0, -0.2, 0);
    colors[imgui.ImGuiCol_Header] = header;
    colors[imgui.ImGuiCol_HeaderHovered] = hsvShiftColor(header, 0, 0, 0.1);
    colors[imgui.ImGuiCol_HeaderActive] = hsvShiftColor(header, 0, 0, -0.1);

    const title = hsvShiftColor(color, 0, 0.1, 0);
    colors[imgui.ImGuiCol_TitleBg] = title;
    colors[imgui.ImGuiCol_TitleBgActive] = title;

    const tab = hsvShiftColor(color, 0, 0.1, 0);
    colors[imgui.ImGuiCol_Tab] = tab;
    colors[imgui.ImGuiCol_TabActive] = hsvShiftColor(tab, 0.05, 0.2, 0.2);
    colors[imgui.ImGuiCol_TabHovered] = hsvShiftColor(tab, 0.02, 0.1, 0.2);
    colors[imgui.ImGuiCol_TabUnfocused] = hsvShiftColor(tab, 0, -0.1, 0);
    colors[imgui.ImGuiCol_TabUnfocusedActive] = colors[imgui.ImGuiCol_TabActive];

    const button = hsvShiftColor(color, -0.05, 0, 0);
    colors[imgui.ImGuiCol_Button] = button;
    colors[imgui.ImGuiCol_ButtonHovered] = hsvShiftColor(button, 0, 0, 0.1);
    colors[imgui.ImGuiCol_ButtonActive] = hsvShiftColor(button, 0, 0, -0.1);
}

fn hsvShiftColor(color: imgui.ImVec4, h_shift: f32, s_shift: f32, v_shift: f32) imgui.ImVec4 {
    var h: f32 = undefined;
    var s: f32 = undefined;
    var v: f32 = undefined;
    imgui.igColorConvertRGBtoHSV(color.x, color.y, color.z, &h, &s, &v);

    h += h_shift;
    s += s_shift;
    v += v_shift;

    var out_color = color;
    imgui.igColorConvertHSVtoRGB(h, s, v, &out_color.x, &out_color.y, &out_color.z);
    return out_color;
}

pub fn toggleObjectMode(enable: bool) void {
    if (enable) {
        setTintColor(colorRgbaVec4(5, 145, 12, 255));
    } else {
        setTintColor(ui_tint);
    }
}

pub fn colorRgb(r: i32, g: i32, b: i32) imgui.ImU32 {
    return imgui.igGetColorU32Vec4(.{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = 1 });
}

pub fn colorRgba(r: i32, g: i32, b: i32, a: i32) imgui.ImU32 {
    return imgui.igGetColorU32Vec4(.{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = @intToFloat(f32, a) / 255 });
}

pub fn colorRgbaVec4(r: i32, g: i32, b: i32, a: i32) imgui.ImVec4 {
    return .{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = @intToFloat(f32, a) / 255 };
}
