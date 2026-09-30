#include "../../include/sdk_video_internal.h"

void func_80064CE0(float factor)
{
    register unsigned int mask;

    mask = func_80067560();
    D_8008F234->vertical.factor = factor;
    D_8008F234->state |= 4;
    func_80067580(mask);
}
