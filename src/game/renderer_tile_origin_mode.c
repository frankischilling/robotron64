#include "../../include/graphics_state_internal.h"

void func_80046C2C(void)
{
    FRAME_COMMAND(0x06000000, D_8007C970);
    FRAME_COMMAND(0xF2000000 |
        GRAPHICS_FIELD((((GraphicsTileState *)D_8013823C)->tileY) & 0xFFF, 0, 12) |
        GRAPHICS_FIELD((((GraphicsTileState *)D_8013823C)->tileX) & 0xFFF, 12, 12),
        GRAPHICS_FIELD((((GraphicsTileState *)D_8013823C)->tileY + 0x7C) & 0xFFF, 0, 12) |
        GRAPHICS_FIELD((((GraphicsTileState *)D_8013823C)->tileX + 0x7C) & 0xFFF, 12, 12));
    FRAME_COMMAND(0xB7000000, 0x20204);
    FRAME_COMMAND(0xBA000E02, 0);
}
