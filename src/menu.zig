const upaya = @import("upaya.zig");
const imgui = upaya.imgui;

pub const MenuItem = struct {
    label: [*c]const u8,
    shortcut: [*c]const u8 = null,
    action: ?fn () void = null,
    children: []const MenuItem = &[_]MenuItem{},

    pub fn draw(self: MenuItem) void {
        if (self.children.len == 0) {
            if (imgui.igMenuItemBool(self.label, self.shortcut, false, true)) {
                if (self.action) |action| action();
            }
        } else {
            self.drawMultiple();
        }
    }

    fn drawMultiple(self: MenuItem) void {
        if (imgui.igBeginMenu(self.label, true)) {
            defer imgui.igEndMenu();
            for (self.children) |child| child.draw();
        }
    }
};

pub fn draw(menuitems: []const MenuItem) void {
    if (imgui.igBeginMenuBar()) {
        for (menuitems) |menu| menu.draw();
        imgui.igEndMenuBar();
    }
}

fn drawMenuItem(_: MenuItem) void {}
