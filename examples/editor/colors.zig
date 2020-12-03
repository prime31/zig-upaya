const std = @import("std");
const upaya = @import("upaya");
usingnamespace @import("imgui");

pub var ui_tint: ImVec4 = upaya.colors.rgbaToVec4(135, 45, 176, 255);

pub var object: ImU32 = 0;
pub var object_selected: ImU32 = 0;
pub var object_drag_link: ImU32 = 0;
pub var object_link: ImU32 = 0;

pub var white: ImU32 = 0;

pub fn init() void {
    setDefaultImGuiStyle();

    object = upaya.colors.rgbToU32(116, 252, 50);
    object_selected = upaya.colors.rgbToU32(282, 172, 247);
    object_drag_link = upaya.colors.rgbToU32(255, 0, 0);
    object_link = upaya.colors.rgbToU32(220, 200, 10);

    white = upaya.colors.rgbToU32(255, 255, 255);
}

fn setDefaultImGuiStyle() void {
    var style = igGetStyle();
    style.TabRounding = 2;
    style.FrameRounding = 4;
    style.WindowBorderSize = 1;
    style.WindowRounding = 0;
    style.WindowMenuButtonPosition = ImGuiDir_None;
    style.Colors[ImGuiCol_WindowBg] = ogColorConvertU32ToFloat4(upaya.colors.rgbaToU32(25, 25, 25, 255));
    style.Colors[ImGuiCol_TextSelectedBg] = ogColorConvertU32ToFloat4(upaya.colors.rgbaToU32(66, 150, 250, 187));

    setTintColor(ui_tint);
}

pub fn setTintColor(color: ImVec4) void {
    var colors = &igGetStyle().Colors;
    colors[ImGuiCol_FrameBg] = hsvShiftColor(color, 0, 0, -0.2);
    colors[ImGuiCol_Border] = hsvShiftColor(color, 0, 0, -0.2);

    const header = hsvShiftColor(color, 0, -0.2, 0);
    colors[ImGuiCol_Header] = header;
    colors[ImGuiCol_HeaderHovered] = hsvShiftColor(header, 0, 0, 0.1);
    colors[ImGuiCol_HeaderActive] = hsvShiftColor(header, 0, 0, -0.1);

    const title = hsvShiftColor(color, 0, 0.1, 0);
    colors[ImGuiCol_TitleBg] = title;
    colors[ImGuiCol_TitleBgActive] = title;

    const tab = hsvShiftColor(color, 0, 0.1, 0);
    colors[ImGuiCol_Tab] = tab;
    colors[ImGuiCol_TabActive] = hsvShiftColor(tab, 0.05, 0.2, 0.2);
    colors[ImGuiCol_TabHovered] = hsvShiftColor(tab, 0.02, 0.1, 0.2);
    colors[ImGuiCol_TabUnfocused] = hsvShiftColor(tab, 0, -0.1, 0);
    colors[ImGuiCol_TabUnfocusedActive] = colors[ImGuiCol_TabActive];

    const button = hsvShiftColor(color, -0.05, 0, 0);
    colors[ImGuiCol_Button] = button;
    colors[ImGuiCol_ButtonHovered] = hsvShiftColor(button, 0, 0, 0.1);
    colors[ImGuiCol_ButtonActive] = hsvShiftColor(button, 0, 0, -0.1);
}

fn hsvShiftColor(color: ImVec4, h_shift: f32, s_shift: f32, v_shift: f32) ImVec4 {
    var h: f32 = undefined;
    var s: f32 = undefined;
    var v: f32 = undefined;
    igColorConvertRGBtoHSV(color.x, color.y, color.z, &h, &s, &v);

    h += h_shift;
    s += s_shift;
    v += v_shift;

    var out_color = color;
    igColorConvertHSVtoRGB(h, s, v, &out_color.x, &out_color.y, &out_color.z);
    return out_color;
}

pub fn toggleObjectMode(enable: bool) void {
    if (enable) {
        setTintColor(colorRgbaVec4(5, 145, 12, 255));
    } else {
        setTintColor(ui_tint);
    }
}
