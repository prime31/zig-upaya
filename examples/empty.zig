const std = @import("std");
const upaya = @import("upaya");
usingnamespace upaya.imgui;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
    });
}

fn init() void {}

fn update() void {
    _ = igBegin("wtf", null, ImGuiWindowFlags_None);
    igText("Hello, world!");
    igText("icon: " ++ upaya.imgui.icons.igloo);
    igEnd();
}