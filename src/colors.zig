const upaya = @import("upaya.zig");
const imgui = upaya.imgui;

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

pub fn hsvShiftColor(color: imgui.ImVec4, h_shift: f32, s_shift: f32, v_shift: f32) imgui.ImVec4 {
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

pub fn rgbToU32(r: i32, g: i32, b: i32) imgui.ImU32 {
    return imgui.ogColorConvertFloat4ToU32(.{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = 1 });
}

pub fn rgbToVec4(r: i32, g: i32, b: i32) imgui.ImVec4 {
    return .{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = 1 };
}

pub fn rgbaToU32(r: i32, g: i32, b: i32, a: i32) imgui.ImU32 {
    return imgui.ogColorConvertFloat4ToU32(.{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = @intToFloat(f32, a) / 255 });
}

pub fn rgbaToVec4(r: i32, g: i32, b: i32, a: i32) imgui.ImVec4 {
    return .{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = @intToFloat(f32, a) };
}
