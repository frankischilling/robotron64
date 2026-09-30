#include "../../include/renderer_geometry_internal.h"

void func_800462DC(unsigned int address)
{
    int alignedAddress = address & ~7;

    if (alignedAddress != D_80123B00) {
        D_80123B00 = alignedAddress;
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xFD500000, alignedAddress);
        FRAME_COMMAND(0xF5500000, 0x07014050);
        FRAME_COMMAND(0xE6000000, 0);
        FRAME_COMMAND(0xF3000000, 0x071FF200);
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xF5480800, 0x00014050);
        FRAME_COMMAND(0xF2000000, 0x0007C07C);
    }
}

void func_800463E8(unsigned int address)
{
    int alignedAddress = address & ~7;

    if (alignedAddress != D_80123B00) {
        D_80123B00 = alignedAddress;
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xFD100000, alignedAddress);
        FRAME_COMMAND(0xF5100000, 0x07014050);
        FRAME_COMMAND(0xE6000000, 0);
        FRAME_COMMAND(0xF3000000, 0x073FF100);
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xF5101000, 0x00014050);
        FRAME_COMMAND(0xF2000000, 0x0007C07C);
    }
}
