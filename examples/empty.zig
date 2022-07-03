const std = @import("std");
const upaya = @import("upaya");
usingnamespace upaya.imgui;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .docking = false,
    });
}

fn init() void {}

fn update() void {
    if (upaya.imgui.igBegin("My First Window", null, upaya.imgui.ImGuiWindowFlags_None)) {
        upaya.imgui.igText("Hello, world!");
        upaya.imgui.igText("We get built-in icons too: " ++ upaya.imgui.icons.igloo);
    }
    upaya.imgui.igEnd();
}
