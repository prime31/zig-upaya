const std = @import("std");
const upaya = @import("upaya");
const ts = @import("../tilescript.zig");
const colors = @import("../colors.zig");
const brushes_win = @import("brushes.zig");
const imgui = @import("imgui");

const Rule = @import("../map.zig").Rule;
const RuleSet = @import("../map.zig").RuleSet;

var rule_label_buf: [25]u8 = undefined;
var group_label_buf: [25]u8 = undefined;
var new_rule_label_buf: [25]u8 = undefined;
var pre_ruleset_tab_buf: [5]u8 = undefined;
var nine_slice_selected: ?usize = null;
var current_ruleset: usize = std.math.maxInt(usize);
var ruleset_delete_index: usize = undefined;

var drag_drop_state = struct {
    source: union(enum) {
        rule: *Rule,
        group: u8,
    } = undefined,
    from: usize = 0,
    to: usize = 0,
    above_group: bool = false,
    completed: bool = false,
    active: bool = false,
    rendering_group: bool = false,
    dropped_in_group: bool = false,

    pub fn isGroup(self: @This()) bool {
        return switch (self.source) {
            .group => true,
            else => false,
        };
    }

    pub fn handle(self: *@This(), rules: *std.ArrayList(Rule)) void {
        self.completed = false;
        switch (self.source) {
            .group => swapGroups(rules),
            else => swapRules(rules),
        }
        self.above_group = false;
    }
}{};

/// used by the fllod fill popup
var fill_dirs = struct {
    left: bool = true,
    right: bool = true,
    up: bool = false,
    down: bool = true,

    pub fn reset(self: *@This()) void {
        self.left = true;
        self.right = true;
        self.down = true;
        self.up = false;
    }

    pub fn valid(self: @This()) bool {
        return self.left or self.right or self.down or self.up;
    }
}{};

fn drawRuleSetTabButtons(state: *ts.AppState, cursor: imgui.ImVec2, open_repeat_popup: *bool) void {
    var cur = cursor;
    cur.x += imgui.igGetWindowContentRegionWidth() - 50;
    cur.y -= 1;
    imgui.igSetCursorPos(cur);

    if (imgui.igButton(imgui.icons.sliders_h, .{})) {
        open_repeat_popup.* = true;
    }
    imgui.igSameLine(0, 5);
    if (imgui.igButton(imgui.icons.plus, .{})) {
        state.map.addPreRuleSet();
    }
    imgui.ogUnformattedTooltip(20, "Adds a new RuleSet, which is a group of rules that transform the input map before regular rules are run");
}

pub fn draw(state: *ts.AppState) void {
    imgui.igPushStyleVarVec2(imgui.ImGuiStyleVar_WindowMinSize, .{ .x = 365 });
    defer imgui.igPopStyleVar(1);

    current_ruleset = std.math.maxInt(usize);
    _ = imgui.igBegin("Rules", null, imgui.ImGuiWindowFlags_None);
    defer imgui.igEnd();

    // save the cursor position so we can hack a button on the tab bar itself or just aligned right
    var cursor = imgui.ogGetCursorPos();
    var open_repeat_popup = false;

    if (state.map.pre_rulesets.items.len > 5) {
        drawRuleSetTabButtons(state, cursor, &open_repeat_popup);
        imgui.igGetCursorStartPos(&cursor);
        cursor.y += imgui.igGetFrameHeightWithSpacing();
        imgui.igSetCursorPos(cursor);
    }

    if (imgui.igBeginTabBar("Rules##tabbar", imgui.ImGuiTabBarFlags_AutoSelectNewTabs | imgui.ImGuiTabBarFlags_FittingPolicyScroll)) {
        defer imgui.igEndTabBar();

        if (state.map.pre_rulesets.items.len <= 5) {
            drawRuleSetTabButtons(state, cursor, &open_repeat_popup);
        }

        if (imgui.igBeginTabItem("Final", null, imgui.ImGuiTabItemFlags_NoCloseButton)) {
            defer imgui.igEndTabItem();
            drawRulesTab(state);
        }

        drawPreRulesTabs(state);

        if (open_repeat_popup) {
            imgui.igOpenPopup("##seed-repeat");
        }
        rulesetSettingsPopup(state);
    }

    if (drag_drop_state.active and imgui.igIsMouseReleased(imgui.ImGuiMouseButton_Left)) {
        drag_drop_state.active = false;
    }
}

/// handles the actual logic to rearrange the Rule for drag/drop when a Rule is reordered
fn swapRules(rules: *std.ArrayList(Rule)) void {
    // dont assign the group unless we are swapping into a group proper
    if (!drag_drop_state.above_group and drag_drop_state.dropped_in_group) {
        const to = if (rules.items.len == drag_drop_state.to) drag_drop_state.to - 1 else drag_drop_state.to;
        const group = rules.items[to].group;
        rules.items[drag_drop_state.from].group = group;
    } else {
        rules.items[drag_drop_state.from].group = 0;
    }

    // get the total number of steps we need to do the swap. We move to index+1 so account for that when moving to a higher index
    var total_swaps = if (drag_drop_state.from > drag_drop_state.to) drag_drop_state.from - drag_drop_state.to else drag_drop_state.to - drag_drop_state.from - 1;
    while (total_swaps > 0) : (total_swaps -= 1) {
        if (drag_drop_state.from > drag_drop_state.to) {
            std.mem.swap(Rule, &rules.items[drag_drop_state.from], &rules.items[drag_drop_state.from - 1]);
            drag_drop_state.from -= 1;
        } else {
            std.mem.swap(Rule, &rules.items[drag_drop_state.from], &rules.items[drag_drop_state.from + 1]);
            drag_drop_state.from += 1;
        }
    }
}

/// handles the actual logic to rearrange the Rule for drag/drop when a group is reordered
fn swapGroups(rules: *std.ArrayList(Rule)) void {
    var total_in_group = blk: {
        var total: usize = 0;
        for (rules.items) |rule| {
            if (rule.group == drag_drop_state.source.group) total += 1;
        }
        break :blk total;
    };
    var total_swaps = if (drag_drop_state.from > drag_drop_state.to) drag_drop_state.from - drag_drop_state.to else drag_drop_state.to - drag_drop_state.from - total_in_group;
    if (total_swaps == 0) return;

    while (total_swaps > 0) : (total_swaps -= 1) {
        // when moving up, we can just move each item in our group up one slot
        if (drag_drop_state.from > drag_drop_state.to) {
            var j: usize = 0;
            while (j < total_in_group) : (j += 1) {
                std.mem.swap(Rule, &rules.items[drag_drop_state.from + j], &rules.items[drag_drop_state.from - 1 + j]);
            }
            drag_drop_state.from -= 1;
        } else {
            // moving down, we have to move the last item in the group first each step
            var j: usize = total_in_group - 1;
            while (j >= 0) : (j -= 1) {
                std.mem.swap(Rule, &rules.items[drag_drop_state.from + j], &rules.items[drag_drop_state.from + 1 + j]);
                if (j == 0) break;
            }
            drag_drop_state.from += 1;
        }
    }
}

fn drawRulesTab(state: *ts.AppState) void {
    var group: u8 = 0;
    var delete_index: usize = std.math.maxInt(usize);
    var i: usize = 0;
    while (i < state.map.ruleset.rules.items.len) : (i += 1) {
        // if we have a Rule in a group render all the Rules in that group at once
        if (state.map.ruleset.rules.items[i].group > 0 and state.map.ruleset.rules.items[i].group != group) {
            group = state.map.ruleset.rules.items[i].group;

            imgui.igPushIDInt(@intCast(c_int, group));
            groupDropTarget(state.map.ruleset.rules.items[i].group, i);
            std.mem.set(u8, &group_label_buf, 0);
            std.mem.copy(u8, &group_label_buf, state.map.getGroupName(group));
            const header_open = imgui.igCollapsingHeaderBoolPtr(&group_label_buf, null, imgui.ImGuiTreeNodeFlags_DefaultOpen);
            groupDragDrop(state.map.ruleset.rules.items[i].group, i);

            if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None) and imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
                imgui.igOpenPopup("##rename-group");
                std.mem.copy(u8, &new_rule_label_buf, state.map.getGroupName(group));
            }

            imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
            if (imgui.igBeginPopup("##rename-group", imgui.ImGuiWindowFlags_None)) {
                _ = imgui.ogInputText("##name", &new_rule_label_buf, new_rule_label_buf.len);

                if (imgui.igButton("Rename Group", .{ .x = -1, .y = 0 })) {
                    imgui.igCloseCurrentPopup();
                    const label_sentinel_index = std.mem.indexOfScalar(u8, &new_rule_label_buf, 0).?;
                    state.map.renameGroup(group, new_rule_label_buf[0..label_sentinel_index]);
                }

                imgui.igEndPopup();
            }
            imgui.igPopID();

            if (header_open) {
                imgui.igIndent(10);
                drag_drop_state.rendering_group = true;
            }
            rulesDragDrop(i, &state.map.ruleset.rules.items[i], true, false);

            while (i < state.map.ruleset.rules.items.len and state.map.ruleset.rules.items[i].group == group) : (i += 1) {
                if (header_open and drawRule(state, &state.map.ruleset, &state.map.ruleset.rules.items[i], i, false)) {
                    delete_index = i;
                }
            }

            if (header_open) {
                imgui.igUnindent(10);
                drag_drop_state.rendering_group = false;
            }

            // if a group is the last item dont try to render any more! else decrement and get back to the loop start since we skipped the last item
            if (i == state.map.ruleset.rules.items.len) break;
            i -= 1;
            continue;
        }

        if (drawRule(state, &state.map.ruleset, &state.map.ruleset.rules.items[i], i, false)) {
            delete_index = i;
        }
    }

    if (delete_index < state.map.ruleset.rules.items.len) {
        const removed = state.map.ruleset.rules.orderedRemove(delete_index);
        if (removed.group > 0) {
            state.map.removeGroupIfEmpty(removed.group);
        }
        state.map_data_dirty = true;
    }

    // handle drag and drop swapping
    if (drag_drop_state.completed) {
        drag_drop_state.handle(&state.map.ruleset.rules);
    }

    if (imgui.ogButton("Add Rule")) {
        state.map.ruleset.addRule();
    }
    imgui.igSameLine(0, 10);

    if (imgui.ogButton("Add 9-Slice")) {
        imgui.igOpenPopup("nine-slice-wizard");
        // reset temp state
        std.mem.set(u8, &new_rule_label_buf, 0);
        nine_slice_selected = null;
    }
    imgui.igSameLine(0, 10);

    if (imgui.ogButton("Add Inner-4")) {
        imgui.igOpenPopup("inner-four-wizard");
        // reset temp state
        std.mem.set(u8, &new_rule_label_buf, 0);
        nine_slice_selected = null;
    }

    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("nine-slice-wizard", imgui.ImGuiWindowFlags_None)) {
        nineSlicePopup(state, 3);
        imgui.igEndPopup();
    }

    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("inner-four-wizard", imgui.ImGuiWindowFlags_None)) {
        nineSlicePopup(state, 2);
        imgui.igEndPopup();
    }
}

fn drawPreRulesTabs(state: *ts.AppState) void {
    for (state.map.pre_rulesets.items) |*ruleset, i| {
        var is_tab_open = true;
        imgui.igPushIDPtr(ruleset);

        std.mem.set(u8, &pre_ruleset_tab_buf, 0);
        _ = std.fmt.bufPrint(&pre_ruleset_tab_buf, imgui.icons.code_branch ++ "{}", .{i}) catch unreachable;
        if (imgui.igBeginTabItem(&pre_ruleset_tab_buf, &is_tab_open, imgui.ImGuiTabItemFlags_None)) {
            defer imgui.igEndTabItem();
            current_ruleset = i;

            var delete_rule_index: usize = std.math.maxInt(usize);
            for (ruleset.rules.items) |*rule, j| {
                if (drawRule(state, ruleset, rule, j, true)) {
                    delete_rule_index = j;
                }
            }

            if (imgui.ogButton("Add Rule")) {
                ruleset.rules.append(Rule.init()) catch unreachable;
            }
            imgui.igSameLine(0, 10);

            if (imgui.ogButton("Add Flood Fill")) {
                imgui.igOpenPopup("flood-fill");
                // reset temp state
                std.mem.set(u8, &new_rule_label_buf, 0);
                fill_dirs.reset();
            }

            if (delete_rule_index < ruleset.rules.items.len) {
                _ = ruleset.rules.orderedRemove(delete_rule_index);
            }

            if (drag_drop_state.completed) {
                drag_drop_state.handle(&ruleset.rules);
                state.map_data_dirty = true;
            }

            floodFillPopup(state, ruleset);
        }
        imgui.igPopID();

        if (!is_tab_open) {
            ruleset_delete_index = i;
            imgui.igOpenPopup("Delete RuleSet");
        }
    } // end pre_rules loop

    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopupModal("Delete RuleSet", null, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        deletePreRuleSetPopup(state);
        imgui.igEndPopup();
    }
}

fn deletePreRuleSetPopup(state: *ts.AppState) void {
    imgui.igText("Are you sure you want to delete\nthis RuleSet?");
     imgui.igSeparator();

    var size = imgui.ogGetContentRegionAvail();
    if (imgui.igButton("Cancel", imgui.ImVec2{ .x = (size.x - 4) / 2 })) {
        imgui.igCloseCurrentPopup();
    }
    imgui.igSameLine(0, 4);

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, ts.colors.colorRgb(180, 25, 35));
    imgui.igPushStyleColorU32(imgui.ImGuiCol_ButtonHovered, ts.colors.colorRgb(240, 20, 30));
    if (imgui.igButton("Delete", imgui.ImVec2{ .x = -1, .y = 0 })) {
        const removed_rules_page = state.map.pre_rulesets.orderedRemove(ruleset_delete_index);
        removed_rules_page.deinit();
        state.map_data_dirty = true;
        imgui.igCloseCurrentPopup();
    }
    imgui.igPopStyleColor(2);
}

fn rulesetSettingsPopup(state: *ts.AppState) void {
    if (imgui.igBeginPopup("##seed-repeat", imgui.ImGuiWindowFlags_None)) {
        var ruleset = if (current_ruleset == std.math.maxInt(usize)) &state.map.ruleset else &state.map.pre_rulesets.items[current_ruleset];
        if (imgui.ogDrag(usize, "Seed", &ruleset.seed, 1, 0, 1000)) {
            state.map_data_dirty = true;
        }

        // only pre_rulesets (valid current_ruleset index into their slice) get the repeat control
        if (current_ruleset < std.math.maxInt(usize) and imgui.ogDrag(u8, "Repeat", &ruleset.repeat, 0.2, 0, 100)) {
            state.map_data_dirty = true;
        }
        imgui.igEndPopup();
    }
}

fn groupDropTarget(_: u8, index: usize) void {
    if (drag_drop_state.active) {
        var cursor = imgui.ogGetCursorPos();
        const old_pos = cursor;
        cursor.y -= 5;
        imgui.igSetCursorPos(cursor);
        imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, colors.colorRgb(0, 255, 0));
        _ = imgui.igInvisibleButton("", .{ .x = -1, .y = 8 });
        imgui.igPopStyleColor(1);
        imgui.igSetCursorPos(old_pos);
    }

    if (imgui.igBeginDragDropTarget()) {
        defer imgui.igEndDragDropTarget();

        if (imgui.igAcceptDragDropPayload("RULESET_DRAG", imgui.ImGuiDragDropFlags_None) != null) {
            drag_drop_state.completed = true;
            drag_drop_state.to = index;
            drag_drop_state.above_group = true;
            drag_drop_state.active = false;
        }
    }
}

fn groupDragDrop(group: u8, index: usize) void {
    if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_SourceNoHoldToOpenOthers)) {
        drag_drop_state.active = true;
        drag_drop_state.from = index;
        drag_drop_state.source = .{ .group = group };
        _ = imgui.igSetDragDropPayload("RULESET_DRAG", null, 0, imgui.ImGuiCond_Once);
        _ = imgui.igButton("group move", .{ .x = imgui.ogGetContentRegionAvail().x, .y = 20 });
        imgui.igEndDragDropSource();
    }
}

/// handles drag/drop sources and targets
fn rulesDragDrop(index: usize, rule: *Rule, drop_only: bool, is_pre_rule: bool) void {
    var cursor = imgui.ogGetCursorPos();

    if (!drop_only) {
        _ = imgui.ogButton(imgui.icons.grip_horizontal);
        imgui.ogUnformattedTooltip(20, if (is_pre_rule or rule.group > 0) "Click and drag to reorder" else "Click and drag to reorder\nRight-click to add a group");

        imgui.igSameLine(0, 4);
        if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_None)) {
            drag_drop_state.active = true;
            _ = imgui.igSetDragDropPayload("RULESET_DRAG", null, 0, imgui.ImGuiCond_Once);
            drag_drop_state.from = index;
            drag_drop_state.source = .{ .rule = rule };
            _ = imgui.igButton(&rule.name, .{ .x = imgui.ogGetContentRegionAvail().x, .y = 20 });
            imgui.igEndDragDropSource();
        }
    }

    // if we are dragging a group dont allow dragging it into another group
    if (drag_drop_state.active and !(drag_drop_state.isGroup() and rule.group > 0)) {
        const old_pos = imgui.ogGetCursorPos();
        cursor.y -= 5;
        imgui.igSetCursorPos(cursor);
        imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, colors.colorRgb(255, 0, 0));
        _ = imgui.igInvisibleButton("", .{ .x = -1, .y = 8 });
        imgui.igPopStyleColor(1);
        imgui.igSetCursorPos(old_pos);

        if (imgui.igBeginDragDropTarget()) {
            if (imgui.igAcceptDragDropPayload("RULESET_DRAG", imgui.ImGuiDragDropFlags_None) != null) {
                drag_drop_state.dropped_in_group = drag_drop_state.rendering_group;
                drag_drop_state.completed = true;
                drag_drop_state.to = index;

                // if this is a group being dragged, we cant rule out the operation since we could have 1 to n items in our group
                if (!drag_drop_state.isGroup()) {
                    // dont allow swapping to the same location, which is the drop target above or below the dragged item
                    if (drag_drop_state.from == drag_drop_state.to or (drag_drop_state.to > 0 and drag_drop_state.from == drag_drop_state.to - 1)) {
                        drag_drop_state.completed = false;
                    }
                }
                drag_drop_state.active = false;
            }
            imgui.igEndDragDropTarget();
        }
    }
}

fn drawRule(state: *ts.AppState, ruleset: *RuleSet, rule: *Rule, index: usize, is_pre_rule: bool) bool {
    imgui.igPushIDPtr(rule);
    defer imgui.igPopID();

    rulesDragDrop(index, rule, false, is_pre_rule);

    // right-click the move button to add the Rule to a group only if not already in a group and not a pre rule
    if (!is_pre_rule and rule.group == 0) {
        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None) and imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
            imgui.igOpenPopup("##group-name");
            std.mem.set(u8, &new_rule_label_buf, 0);
        }

        imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##group-name", imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndPopup();

            _ = imgui.ogInputText("##group-name", &new_rule_label_buf, new_rule_label_buf.len);

            const label_sentinel_index = std.mem.indexOfScalar(u8, &new_rule_label_buf, 0).?;
            const disabled = label_sentinel_index == 0;
            if (disabled) {
                imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
                imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
            }

            if (imgui.igButton("Add to New Group", .{ .x = -1, .y = 0 })) {
                imgui.igCloseCurrentPopup();

                // get the next available group
                rule.group = ruleset.getNextAvailableGroup(&state.map, new_rule_label_buf[0..label_sentinel_index]);
                std.mem.set(u8, &new_rule_label_buf, 0);
            }

            if (disabled) {
                imgui.igPopItemFlag();
                imgui.igPopStyleVar(1);
            }
        }
    }

    imgui.igPushItemWidth(115);
    std.mem.copy(u8, &rule_label_buf, &rule.name);
    if (imgui.ogInputText("##name", &rule_label_buf, rule_label_buf.len)) {
        std.mem.copy(u8, &rule.name, &rule_label_buf);
    }
    imgui.igPopItemWidth();
    imgui.igSameLine(0, 4);

    if (imgui.ogButton("Pattern")) {
        imgui.igOpenPopup("##pattern_popup");
    }
    imgui.igSameLine(0, 4);

    if (imgui.ogButton("Result")) {
        imgui.igOpenPopup("result_popup");
    }
    imgui.igSameLine(0, 4);

    imgui.igPushItemWidth(50);
    var min: u8 = 0;
    var max: u8 = 100;
    _ = imgui.igDragScalar("", imgui.ImGuiDataType_U8, &rule.chance, 1, &min, &max, null, 1);
    imgui.igSameLine(0, 4);

    if (imgui.ogButton(imgui.icons.copy)) {
        ruleset.rules.append(rule.clone()) catch unreachable;
    }
    imgui.igSameLine(0, 4);

    if (imgui.ogButton(imgui.icons.trash)) {
        return true;
    }

    // if this is the last item, add an extra drop zone for reordering
    if (index == ruleset.rules.items.len - 1) {
        rulesDragDrop(index + 1, rule, true, is_pre_rule);
    }

    // display the popup a bit to the left to center it under the mouse
    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("##pattern_popup", imgui.ImGuiWindowFlags_None)) {
        patternPopup(state, rule);

        var size = imgui.ogGetContentRegionAvail();
        if (imgui.igButton("Clear", imgui.ImVec2{ .x = (size.x - 4) / 1.7 })) {
            rule.clearPatternData();
        }
        imgui.igSameLine(0, 4);

        if (imgui.igButton("...", .{ .x = -1, .y = 0 })) {
            imgui.igOpenPopup("rules_hamburger");
        }

        rulesHamburgerPopup(state, rule);

        // quick brush selector
        if (imgui.ogKeyPressed(upaya.sokol.SAPP_KEYCODE_B)) {
            if (imgui.igIsPopupOpenID(imgui.igGetIDStr("##brushes"))) {
                imgui.igClosePopupToLevel(1, true);
            } else {
                imgui.igOpenPopup("##brushes");
            }
        }
        brushes_win.drawPopup(state, "##brushes");
        imgui.igEndPopup();
    }

    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("result_popup", imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        resultPopup(state, rule, is_pre_rule);
        imgui.igEndPopup();
    }

    return false;
}

fn patternPopup(state: *ts.AppState, rule: *Rule) void {
    imgui.igText("Pattern");
    imgui.igSameLine(0, imgui.igGetWindowContentRegionWidth() - 65);
    imgui.igText(imgui.icons.question_circle);
    imgui.ogUnformattedTooltip(100, "Left Click: select tile and require\nShift + Left Click: select tile and negate\nRight Click: set as empty required\nShift + Right Click: set as empty negated");

    const draw_list = imgui.igGetWindowDrawList();

    const rect_size: f32 = 16;
    const pad: f32 = 4;
    const canvas_size = 5 * rect_size + 4 * pad;
    const thickness: f32 = 2;

    var pos = imgui.ImVec2{};
    imgui.igGetCursorScreenPos(&pos);
    _ = imgui.igInvisibleButton("##pattern_button", imgui.ImVec2{ .x = canvas_size, .y = canvas_size });
    const mouse_pos = imgui.igGetIO().MousePos;
    const hovered = imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None);

    var y: usize = 0;
    while (y < 5) : (y += 1) {
        var x: usize = 0;
        while (x < 5) : (x += 1) {
            const pad_x = @intToFloat(f32, x) * pad;
            const pad_y = @intToFloat(f32, y) * pad;
            const offset_x = @intToFloat(f32, x) * rect_size;
            const offset_y = @intToFloat(f32, y) * rect_size;
            var tl = imgui.ImVec2{ .x = pos.x + pad_x + offset_x, .y = pos.y + pad_y + offset_y };

            var rule_tile = rule.get(x, y);
            if (rule_tile.tile > 0) {
                brushes_win.drawBrush(rect_size, rule_tile.tile - 1, tl);
            } else {
                // if empty rule or just with a modifier
                imgui.ogAddQuadFilled(draw_list, tl, rect_size, colors.colorRgb(0, 0, 0));
            }

            if (x == 2 and y == 2) {
                const size = rect_size - thickness;
                var tl2 = tl;
                tl2.x += 1;
                tl2.y += 1;
                imgui.ogAddQuad(draw_list, tl2, size, colors.pattern_center, thickness);
            }

            tl.x -= 1;
            tl.y -= 1;
            if (rule_tile.state == .negated) {
                const size = rect_size + thickness;
                imgui.ogAddQuad(draw_list, tl, size, colors.brush_negated, thickness);
            } else if (rule_tile.state == .required) {
                const size = rect_size + thickness;
                imgui.ogAddQuad(draw_list, tl, size, colors.brush_required, thickness);
            }

            if (hovered) {
                if (tl.x <= mouse_pos.x and mouse_pos.x < tl.x + rect_size and tl.y <= mouse_pos.y and mouse_pos.y < tl.y + rect_size) {
                    if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
                        state.map_data_dirty = true;
                        if (imgui.igGetIO().KeyShift) {
                            rule_tile.negate(state.selected_brush_index + 1);
                        } else {
                            rule_tile.require(state.selected_brush_index + 1);
                        }
                    }

                    if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Right, false)) {
                        state.map_data_dirty = true;
                        rule_tile.toggleState(if (imgui.igGetIO().KeyShift) .negated else .required);
                    }
                }
            }
        }
    }
}

fn rulesHamburgerPopup(state: *ts.AppState, rule: *Rule) void {
    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("rules_hamburger", imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();
        state.map_data_dirty = true;

        imgui.igText("Shift:");
        imgui.igSameLine(0, 10);
        if (imgui.ogButton(imgui.icons.arrow_left)) {
            rule.shift(.left);
        }

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(imgui.icons.arrow_up)) {
            rule.shift(.up);
        }

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(imgui.icons.arrow_down)) {
            rule.shift(.down);
        }

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(imgui.icons.arrow_right)) {
            rule.shift(.right);
        }

        imgui.igText("Flip: ");
        imgui.igSameLine(0, 10);
        if (imgui.ogButton(imgui.icons.arrows_alt_h)) {
            rule.flip(.horizontal);
        }

        imgui.igSameLine(0, 4);
        if (imgui.ogButton(imgui.icons.arrows_alt_v)) {
            rule.flip(.vertical);
        }
    }
}

fn floodFillPopup(state: *ts.AppState, ruleset: *RuleSet) void {
    imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("flood-fill", imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();

        imgui.igText("Directions:");
        imgui.igSameLine(0, 10);
        _ = imgui.igSelectableBoolPtr(imgui.icons.arrow_left, &fill_dirs.left, imgui.ImGuiSelectableFlags_DontClosePopups, .{ .x = 12, .y = 12 });

        imgui.igSameLine(0, 7);
        _ = imgui.igSelectableBoolPtr(imgui.icons.arrow_down, &fill_dirs.down, imgui.ImGuiSelectableFlags_DontClosePopups, .{ .x = 12, .y = 12 });

        imgui.igSameLine(0, 7);
        _ = imgui.igSelectableBoolPtr(imgui.icons.arrow_right, &fill_dirs.right, imgui.ImGuiSelectableFlags_DontClosePopups, .{ .x = 12, .y = 12 });

        imgui.igSameLine(0, 7);
        _ = imgui.igSelectableBoolPtr(imgui.icons.arrow_up, &fill_dirs.up, imgui.ImGuiSelectableFlags_DontClosePopups, .{ .x = 12, .y = 12 });

        imgui.igSpacing();
        var size = imgui.ogGetContentRegionAvail();
        imgui.igSetNextItemWidth(size.x * 0.6);
        _ = imgui.ogInputText("##nine-slice-name", &new_rule_label_buf, new_rule_label_buf.len);
        imgui.igSameLine(0, 5);

        const label_sentinel_index = std.mem.indexOfScalar(u8, &new_rule_label_buf, 0).?;
        const disabled = label_sentinel_index == 0 or !fill_dirs.valid();

        if (disabled) {
            imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
            imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
        }

        if (imgui.igButton("Create", imgui.ImVec2{ .x = -1, .y = 0 })) {
            imgui.igCloseCurrentPopup();
            state.map_data_dirty = true;
            ruleset.addFloodFill(state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], fill_dirs.left, fill_dirs.right, fill_dirs.up, fill_dirs.down);
        }

        if (disabled) {
            imgui.igPopItemFlag();
            imgui.igPopStyleVar(1);
        }
    }
}

/// shows the tileset or brush palette allowing multiple tiles to be selected
fn resultPopup(state: *ts.AppState, ruleset: *Rule, is_pre_rule: bool) void {
    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (!is_pre_rule and (state.texture.width < 200 and state.texture.height < 200)) 2 else 1;
    const tile_spacing = if (is_pre_rule) 0 else state.map.tile_spacing * zoom;
    const tile_size = if (is_pre_rule) 32 else state.map.tile_size * zoom;

    if (is_pre_rule) {
        brushes_win.draw(state, @intToFloat(f32, tile_size), true);
    } else {
        imgui.ogImage(state.texture.imTextureID(), state.texture.width * @intCast(i32, zoom), state.texture.height * @intCast(i32, zoom));
    }

    // draw selected tiles
    var iter = ruleset.result_tiles.iter();
    while (iter.next()) |index| {
        const per_row = if (is_pre_rule) 6 else state.tilesPerRow();
        ts.addTileToDrawList(tile_size, content_start_pos, index, per_row, tile_spacing);
    }

    // check input for toggling state
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(0, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, tile_size + tile_spacing), content_start_pos);
            const per_row = if (is_pre_rule) 6 else state.tilesPerRow();
            ruleset.toggleSelected(@intCast(u8, tile.x + tile.y * per_row));
            state.map_data_dirty = true;
        }
    }

    if (imgui.igButton("Clear", imgui.ImVec2{ .x = -1 })) {
        ruleset.result_tiles.clear();
        state.map_data_dirty = true;
    }
}

fn nineSlicePopup(state: *ts.AppState, selection_size: usize) void {
    brushes_win.draw(state, 16, false);
    imgui.igSameLine(0, 5);

    var content_start_pos = imgui.ogGetCursorScreenPos();
    imgui.ogImage(state.texture.imTextureID(), state.texture.width, state.texture.height);

    const draw_list = imgui.igGetWindowDrawList();

    if (nine_slice_selected) |index| {
        const x = @mod(index, state.tilesPerRow());
        const y = @divTrunc(index, state.tilesPerRow());

        var tl = imgui.ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) };
        tl.x += content_start_pos.x + 1 + @intToFloat(f32, state.map.tile_spacing);
        tl.y += content_start_pos.y + 1 + @intToFloat(f32, state.map.tile_spacing);
        imgui.ogAddQuadFilled(draw_list, tl, @intToFloat(f32, (state.map.tile_size + state.map.tile_spacing) * selection_size), colors.rule_result_selected_fill);
        imgui.ogAddQuad(draw_list, tl, @intToFloat(f32, (state.map.tile_size + state.map.tile_spacing) * selection_size) - 1, colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(0, false)) {
            var tile = ts.tileIndexUnderMouse(@intCast(usize, state.map.tile_size + state.map.tile_spacing), content_start_pos);

            // does the nine-slice fit?
            if (tile.x + selection_size <= state.tilesPerRow() and tile.y + selection_size <= state.tilesPerCol()) {
                nine_slice_selected = @intCast(usize, tile.x + tile.y * state.tilesPerRow());
            }
        }
    }

    var size = imgui.ogGetContentRegionAvail();
    imgui.igSetNextItemWidth(size.x * 0.6);
    _ = imgui.ogInputText("##nine-slice-name", &new_rule_label_buf, new_rule_label_buf.len);
    imgui.igSameLine(0, 5);

    const label_sentinel_index = std.mem.indexOfScalar(u8, &new_rule_label_buf, 0).?;
    const disabled = label_sentinel_index == 0 or nine_slice_selected == null;
    if (disabled) {
        imgui.igPushItemFlag(imgui.ImGuiItemFlags_Disabled, true);
        imgui.igPushStyleVarFloat(imgui.ImGuiStyleVar_Alpha, 0.5);
    }

    if (imgui.igButton("Create", imgui.ImVec2{ .x = -1, .y = 0 })) {
        if (selection_size == 3) {
            state.map.ruleset.addNinceSliceRules(&state.map, state.tilesPerRow(), state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        } else {
            state.map.ruleset.addInnerFourRules(&state.map, state.tilesPerRow(), state.selected_brush_index, new_rule_label_buf[0..label_sentinel_index], nine_slice_selected.?);
        }
        state.map_data_dirty = true;
        imgui.igCloseCurrentPopup();
    }

    if (disabled) {
        imgui.igPopItemFlag();
        imgui.igPopStyleVar(1);
    }
}
