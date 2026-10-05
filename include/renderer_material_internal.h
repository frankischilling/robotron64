#ifndef ROBOTRON_RENDERER_MATERIAL_INTERNAL_H
#define ROBOTRON_RENDERER_MATERIAL_INTERNAL_H

#include "graphics_state_internal.h"
#include "resource_bridge_internal.h"

/* The model cache starts 20 bytes into the arena and uses a 20-byte stride.
 * This prefix view addresses its word at arena offset 24 for each index. */
typedef struct RendererMaterialSlotView {
    unsigned char unknown00[24];
    unsigned int flags;
} RendererMaterialSlotView;

typedef char RendererMaterialSlotPrefixMustBe28Bytes[
    sizeof(RendererMaterialSlotView) == 28 ? 1 : -1];

extern TextGlyphResource D_8009F560[];

#endif
