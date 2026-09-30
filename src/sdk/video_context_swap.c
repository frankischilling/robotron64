#include "../../include/sdk_video_internal.h"
#include "../../include/sdk_io.h"

void func_8006AC90(void)
{
    register VideoMode *mode;
    register SdkVideoContext *context;
    unsigned int origin;
    unsigned int hStart;
    unsigned int nominal;
    unsigned int field;

    field = 0;
    context = D_8008F234;
    mode = context->mode;
    field = *(volatile unsigned int *)0xA4400010 & 1;
    origin = func_800606A0(context->framebuffer) + mode->fields[field].origin;
    if (context->state & 2) {
        context->horizontal.scale |= mode->xScale & ~0xFFF;
    } else {
        context->horizontal.scale = mode->xScale;
    }
    if (context->state & 4) {
        nominal = mode->fields[field].yScale & 0xFFF;
        context->vertical.scale = context->vertical.factor * nominal;
        context->vertical.scale |= mode->fields[field].yScale & ~0xFFF;
    } else {
        context->vertical.scale = mode->fields[field].yScale;
    }
    hStart = mode->hStart;
    if (context->state & 0x20) {
        hStart = 0;
    }
    if (context->state & 0x40) {
        context->vertical.scale = 0;
        origin = func_800606A0(context->framebuffer);
    }
    if (context->state & 0x80) {
        context->vertical.scale = (context->vertical.offset << 16) & 0x3FF0000;
        origin = func_800606A0(context->framebuffer);
    }
    *(volatile unsigned int *)0xA4400004 = origin;
    *(volatile unsigned int *)0xA4400008 = mode->width;
    *(volatile unsigned int *)0xA4400014 = mode->burst;
    *(volatile unsigned int *)0xA4400018 = mode->vSync;
    *(volatile unsigned int *)0xA440001C = mode->hSync;
    *(volatile unsigned int *)0xA4400020 = mode->leap;
    *(volatile unsigned int *)0xA4400024 = hStart;
    *(volatile unsigned int *)0xA4400028 = mode->fields[field].vStart;
    *(volatile unsigned int *)0xA440002C = mode->fields[field].vBurst;
    *(volatile unsigned int *)0xA440000C = mode->fields[field].vInterrupt;
    *(volatile unsigned int *)0xA4400030 = context->horizontal.scale;
    *(volatile unsigned int *)0xA4400034 = context->vertical.scale;
    *(volatile unsigned int *)0xA4400000 = context->control;
    D_8008F234 = D_8008F230;
    D_8008F230 = context;
    *D_8008F234 = *D_8008F230;
}
