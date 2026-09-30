#include "../../include/renderer_geometry_internal.h"

void func_80043EEC(RendererPolygon *polygon)
{
    polygon->colorIndex = (polygon->colors[0] >> 24) & 0xFF;
    FRAME_COMMAND(0xFC127E24, 0xFFFFF9FC);
    FRAME_COMMAND(0xB6000000, 0x00040000);
    D_80123AD4 = polygon->textureIndex;
    if (D_80123AD4 != 255) {
        D_80123AE0 = polygon->textureCorners;
        if (D_80123AD4 != D_80123AD8) {
            D_80123AD8 = D_80123AD4;
            func_800462DC((D_80123AD4 << 10) + D_800BF5E8);
            func_80049AD8(D_8007D6D0);
        }
        if (D_8007CDAC == 0) {
            func_8004ABC8();
            FRAME_COMMAND(0xFC127E24, 0xFFFFF9FC);
            FRAME_COMMAND(0xB6000000, 0x00040000);
            D_8007CDAC = 1;
        }
    } else if (D_8007CDAC != 0) {
        D_8007CDAC = 0;
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
    }
    if (D_80123ADC != polygon->colorIndex) {
        D_80123ADC = polygon->colorIndex;
        if (D_80123ADC == 254) {
            FRAME_COMMAND(0xE7000000, 0);
            FRAME_COMMAND(0xB900031D, 0x005049D8);
            D_80123AE8 = 192;
            FRAME_COMMAND(0x03860010, &D_80123B28[1]);
            return;
        }
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xB900031D, 0x00552078);
        FRAME_COMMAND(0x03860010, &D_80123B28[D_80123ADC]);
    }
}
