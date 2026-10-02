#include "../../include/renderer_image_setup_internal.h"

void func_80049DB0(void)
{
    FRAME_COMMAND(0xB9000002, 0);
}

void func_80049DD8(int x, int y, int z)
{
    D_8013D9A0 = x;
    D_8013D9A4 = y;
    D_8013D9A8 = z;
}

void func_80049DF4(int x, int y, int z)
{
    D_8008CB24 = x;
    D_8008CB28 = y;
    D_8008CB2C = z;
}

void func_80049E10(int value)
{
    D_8008CB34 = value >> 4;
    D_8008CB30 = (float)value / 256;
}
