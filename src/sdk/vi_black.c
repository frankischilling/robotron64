#include "../../include/sdk_video_internal.h"

void osViBlack(unsigned char enabled)
{
    register unsigned int mask;

    mask = func_80067560();
    if (enabled) {
        D_8008F234->state |= 0x20;
    } else {
        D_8008F234->state &= ~0x20;
    }
    func_80067580(mask);
}
