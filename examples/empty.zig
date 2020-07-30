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
    if (igBegin("My First Window", null, ImGuiWindowFlags_None)) {
        igText("Hello, world!");
        igText("We get built-in icons too: " ++ icons.igloo);
    }
    igEnd();
}