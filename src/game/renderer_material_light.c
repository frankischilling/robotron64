#include "../../include/renderer_geometry_internal.h"

void func_80043E80(RendererPolygon *polygon)
{
    unsigned int color = polygon->colors[0];

    polygon->colorIndex = (color >> 24) & 0xFF;
    if (D_80123ADC != polygon->colorIndex) {
        D_80123ADC = polygon->colorIndex;
        FRAME_COMMAND(0x03860010, &D_80123B28[D_80123ADC]);
    }
}

void func_80043EE4(int unused)
{
}
