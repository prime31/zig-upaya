pub const stbrp_context = extern struct {
    width: c_int,
    height: c_int,
    @"align": c_int,
    init_mode: c_int,
    heuristic: c_int,
    num_nodes: c_int,
    active_head: [*c]stbrp_node,
    free_head: [*c]stbrp_node,
    extra: [2]stbrp_node,
};

pub const stbrp_node = extern struct {
    x: c_ushort,
    y: c_ushort,
    next: [*c]stbrp_node,
};

pub const stbrp_rect = extern struct {
    id: c_int,
    w: c_ushort,
    h: c_ushort,
    x: c_ushort = 0,
    y: c_ushort = 0,
    was_packed: c_int = 0,
};

pub extern fn stbrp_pack_rects(context: [*c]stbrp_context, rects: [*c]stbrp_rect, num_rects: c_int) c_int;
pub extern fn stbrp_init_target(context: [*c]stbrp_context, width: c_int, height: c_int, nodes: [*c]stbrp_node, num_nodes: c_int) void;
pub extern fn stbrp_setup_allow_out_of_mem(context: [*c]stbrp_context, allow_out_of_mem: c_int) void;
pub extern fn stbrp_setup_heuristic(context: [*c]stbrp_context, heuristic: c_int) void;

pub const STBRP_HEURISTIC_Skyline_default = @enumToInt(enum_unnamed_1.STBRP_HEURISTIC_Skyline_default);
pub const STBRP_HEURISTIC_Skyline_BL_sortHeight = @enumToInt(enum_unnamed_1.STBRP_HEURISTIC_Skyline_BL_sortHeight);
pub const STBRP_HEURISTIC_Skyline_BF_sortHeight = @enumToInt(enum_unnamed_1.STBRP_HEURISTIC_Skyline_BF_sortHeight);
const enum_unnamed_1 = extern enum(c_int) {
    STBRP_HEURISTIC_Skyline_default = 0,
    STBRP_HEURISTIC_Skyline_BL_sortHeight = 0,
    STBRP_HEURISTIC_Skyline_BF_sortHeight = 1,
    _,
};