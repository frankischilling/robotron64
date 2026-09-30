#include "../../include/graphics_state_internal.h"

void func_800474B8(int alpha)
{
    if (alpha != D_80123B0C) {
        D_80123B0C = alpha;
        FRAME_COMMAND(0xFB000000, alpha & 0xFF);
    }
}

void func_800474F8(int red, int green, int blue)
{
    if ((red | green | blue) != 0) {
        FRAME_COMMAND(0xFB000000,
                      (((unsigned int)red & 0xFF) << 24) |
                      (((unsigned int)green & 0xFF) << 16) |
                      (((unsigned int)blue & 0xFF) << 8) | 0xFF);
        func_8004729C(17);
    }
}
