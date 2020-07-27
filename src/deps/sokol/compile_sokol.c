#define SOKOL_IMPL

#ifdef __APPLE__
#define SOKOL_METAL
#else
#define SOKOL_GLCORE33
#endif

#define SOKOL_NO_ENTRY
#define SOKOL_NO_DEPRECATED
#include "sokol/sokol_app.h"
#include "sokol/sokol_gfx.h"
#include "sokol/sokol_glue.h"
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui/cimgui.h"
#define SOKOL_IMGUI_IMPL
#include "sokol/util/sokol_imgui.h"