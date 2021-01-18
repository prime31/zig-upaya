#include "cimgui/imgui/imgui.h"
#include "cimgui/imgui/imgui_internal.h"
#include "cimgui/cimgui.h"

CIMGUI_API void _ogImDrawData_ScaleClipRects(ImDrawData* self, const float fb_scale) {
    ImVec2 fb_scale_vec;
    fb_scale_vec.x = fb_scale;
    fb_scale_vec.y = fb_scale;
    self->ScaleClipRects(fb_scale_vec);
}

// workaround for Windows not functioning with ImVec4s
CIMGUI_API void _ogImage(ImTextureID user_texture_id, const ImVec2* size, const ImVec2* uv0, const ImVec2* uv1) {
    ImVec4 tint_col;
    tint_col.x = tint_col.y = tint_col.z = tint_col.w = 1;
    ImVec4 border_col;
    return ImGui::Image(user_texture_id, *size, *uv0, *uv1, tint_col, border_col);
}

CIMGUI_API bool _ogImageButton(ImTextureID user_texture_id, const ImVec2* size, const ImVec2* uv0, const ImVec2* uv1, int frame_padding) {
    ImVec4 tint_col;
    tint_col.x = tint_col.y = tint_col.z = tint_col.w = 1;
    ImVec4 border_col;
    return ImGui::ImageButton(user_texture_id, *size, *uv0, *uv1, frame_padding, border_col, tint_col);
}

CIMGUI_API void _ogColoredText(float r, float g, float b, const char* text) {
    ImVec4 tint_col;
    tint_col.x = r;
    tint_col.y = g;
    tint_col.z = b;
    tint_col.w = 1;
    ImGui::TextColored(tint_col, text);
}

CIMGUI_API ImU32 _ogColorConvertFloat4ToU32(ImVec4* color) {
    return ImGui::ColorConvertFloat4ToU32(*color);
} 

// M1 needs this for some reason...
CIMGUI_API bool _ogButton(const char* label, const float x, const float y) {
    ImVec2 size;
    size.x = x;
    size.y = y;
    return ImGui::Button(label, size);
}

CIMGUI_API void _ogDockBuilderSetNodeSize(ImGuiID node_id, const ImVec2* size) {
    return ImGui::DockBuilderSetNodeSize(node_id, *size);
}

CIMGUI_API void _ogSetNextWindowPos(const ImVec2* pos, ImGuiCond cond, const ImVec2* pivot) {
    return ImGui::SetNextWindowPos(*pos, cond, *pivot);
}

CIMGUI_API void _ogSetNextWindowSize(const ImVec2* size, ImGuiCond cond) {
    return ImGui::SetNextWindowSize(*size, cond);
}

CIMGUI_API void _ogPushStyleVarVec2(ImGuiStyleVar idx, const float x, const float y) {
    ImVec2 pos;
    pos.x = x;
    pos.y = y;
    return ImGui::PushStyleVar(idx, pos);
}

CIMGUI_API bool _ogInvisibleButton(const char* str_id, const float w, const float h, ImGuiButtonFlags flags) {
    ImVec2 size;
    size.x = w;
    size.y = h;
    return ImGui::InvisibleButton(str_id, size);
}

CIMGUI_API bool _ogSelectableBool(const char* label, bool selected, ImGuiSelectableFlags flags, const float w, const float h) {
    ImVec2 size;
    size.x = w;
    size.y = h;
    return ImGui::Selectable(label, selected, flags, size);
}

CIMGUI_API void _ogDummy(const float w, const float h) {
    ImVec2 size;
    size.x = w;
    size.y = h;
    return ImGui::Dummy(size);
}

CIMGUI_API bool _ogBeginChildFrame(ImGuiID id, const float w, const float h, ImGuiWindowFlags flags) {
    ImVec2 size;
    size.x = w;
    size.y = h;
    return ImGui::BeginChildFrame(id, size, flags);
}

CIMGUI_API bool _ogBeginChildEx(const char* name, ImGuiID id, const ImVec2* size_arg, bool border, ImGuiWindowFlags flags) {
    return ImGui::BeginChildEx(name, id, *size_arg, border, flags);
}

CIMGUI_API void _ogDockSpace(ImGuiID id, const float w, const float h, ImGuiDockNodeFlags flags, const ImGuiWindowClass* window_class) {
    ImVec2 size;
    size.x = w;
    size.y = h;
    return ImGui::DockSpace(id, size, flags, window_class);
}

CIMGUI_API void _ogImDrawList_AddQuad(ImDrawList* self, const ImVec2* p1, const ImVec2* p2, const ImVec2* p3, const ImVec2* p4, ImU32 col, float thickness) {
    return self->AddQuad(*p1, *p2, *p3, *p4, col, thickness);
}

CIMGUI_API void _ogImDrawList_AddQuadFilled(ImDrawList* self, const ImVec2* p1, const ImVec2* p2, const ImVec2* p3, const ImVec2* p4, ImU32 col) {
    return self->AddQuadFilled(*p1, *p2, *p3, *p4, col);
}

CIMGUI_API void _ogImDrawList_AddImage(ImDrawList* self, ImTextureID id, const ImVec2* p_min, const ImVec2* p_max, const ImVec2* uv_min, const ImVec2* uv_max, ImU32 col) {
    return self->AddImage(id, *p_min, *p_max, *uv_min, *uv_max, col);
}

CIMGUI_API void _ogImDrawList_AddLine(ImDrawList* self, const ImVec2* p1, const ImVec2* p2, ImU32 col, float thickness) {
    return self->AddLine(*p1, *p2, col, thickness);
}

CIMGUI_API void _ogSetCursorScreenPos(const ImVec2* pos) {
    return ImGui::SetCursorScreenPos(*pos);
}

CIMGUI_API bool _ogListBoxHeaderVec2(const char* label, const ImVec2* size) {
    return ImGui::ListBoxHeader(label, *size);
}