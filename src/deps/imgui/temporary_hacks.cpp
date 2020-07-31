#include "cimgui/imgui/imgui.h"
#include "cimgui/imgui/imgui_internal.h"
#include "cimgui/cimgui.h"

// workaround for Windows not functioning with ImVec4s
CIMGUI_API void _ogImage(ImTextureID user_texture_id, const ImVec2 size, const ImVec2 uv0, const ImVec2 uv1) {
    ImVec4 tint_col;
    tint_col.x = tint_col.y = tint_col.z = tint_col.w = 1;
    ImVec4 border_col;
    return ImGui::Image(user_texture_id, size, uv0, uv1, tint_col, border_col);
}

CIMGUI_API bool _ogImageButton(ImTextureID user_texture_id, const ImVec2 size, const ImVec2 uv0, const ImVec2 uv1, int frame_padding) {
    ImVec4 tint_col;
    tint_col.x = tint_col.y = tint_col.z = tint_col.w = 1;
    ImVec4 border_col;
    return ImGui::ImageButton(user_texture_id, size, uv0, uv1, frame_padding, border_col, tint_col);
}