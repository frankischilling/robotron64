#include "../../include/renderer_geometry_internal.h"

void func_80043D68(RendererPolygon *polygon)
{
    polygon->colorIndex = (polygon->colors[0] >> 24) & 0xFF;
    D_80123AD4 = polygon->textureIndex;
    if (D_80123AD4 != 255) {
        polygon->colorIndex = 254;
        polygon->colors[0] = -1;
        D_80123AE0 = polygon->textureCorners;
        if (D_80123AD4 != D_80123AD8) {
            D_80123AD8 = D_80123AD4;
            func_800462DC((D_80123AD4 << 10) + D_800BF5E8);
        }
        func_80049AD8(D_8007D6D0);
        if (D_8007CDAC == 0) {
            FRAME_COMMAND(0xFCFFFFFF, 0xFFFCF87C);
            D_8007CDAC = 1;
        }
    } else if (D_8007CDAC != 0) {
        D_8007CDAC = 0;
        FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
    }
}
