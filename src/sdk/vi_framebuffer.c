#include "../../include/sdk_video_internal.h"

void func_80065620(void *framebuffer)
{
    unsigned int mask;

    mask = func_80067560();
    D_8008F234->framebuffer = framebuffer;
    D_8008F234->state |= 0x10;
    func_80067580(mask);
}

void *func_80065670(void)
{
    register unsigned int mask;
    void *framebuffer;

    mask = func_80067560();
    framebuffer = D_8008F230->framebuffer;
    func_80067580(mask);
    return framebuffer;
}

void *func_800656B0(void)
{
    register unsigned int mask;
    void *framebuffer;

    mask = func_80067560();
    framebuffer = D_8008F234->framebuffer;
    func_80067580(mask);
    return framebuffer;
}
