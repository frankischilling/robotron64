#include "../../include/sdk_video_internal.h"

void osViSetSpecialFeatures(unsigned int features)
{
    register unsigned int mask;

    mask = func_80067560();
    if (features & 1) {
        D_8008F234->control |= 8;
    }
    if (features & 2) {
        D_8008F234->control &= ~8;
    }
    if (features & 4) {
        D_8008F234->control |= 4;
    }
    if (features & 8) {
        D_8008F234->control &= ~4;
    }
    if (features & 0x10) {
        D_8008F234->control |= 0x10;
    }
    if (features & 0x20) {
        D_8008F234->control &= ~0x10;
    }
    if (features & 0x40) {
        D_8008F234->control |= 0x10000;
        D_8008F234->control &= ~0x300;
    }
    if (features & 0x80) {
        D_8008F234->control &= ~0x10000;
        D_8008F234->control |= D_8008F234->mode->control & 0x300;
    }
    D_8008F234->state |= 8;
    func_80067580(mask);
}
