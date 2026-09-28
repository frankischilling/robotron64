#include "../../include/renderer_geometry_internal.h"

void func_800441D0(RendererPolygon *polygon)
{
    polygon->colorIndex = (polygon->colors[0] >> 24) & 0xFF;
    D_80123AD4 = 255;
    if (D_80123AD4 != 255) {
        polygon->colorIndex = 254;
        polygon->colors[0] = -1;
        D_80123AE0 = polygon->textureCorners;
        if (D_80123AD4 != D_80123AD8) {
            D_80123AD8 = D_80123AD4;
        }
        if (D_8007CDAC == 0) {
            D_8007CDAC = 1;
        }
    } else if (D_8007CDAC != 0) {
        D_8007CDAC = 0;
    }
}
