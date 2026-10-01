#ifndef ROBOTRON_RENDERER_DRAW_STATE_INTERNAL_H
#define ROBOTRON_RENDERER_DRAW_STATE_INTERNAL_H

#include "object_draw.h"
#include "frame.h"
#include "fixed_math.h"

/* Draw fields occupy ObjectRecord offsets 0x38..0x74; model follows them. */
typedef struct RendererDrawState {
    unsigned int flags;
    int scale[3];
    int angle[3];
    int position[3];
    int projectedPosition[3];
    ObjectDrawResource *resource;
    int value;
} RendererDrawState;

typedef char RendererDrawStateMustBe60Bytes[
    sizeof(RendererDrawState) == 0x3C ? 1 : -1];

extern unsigned char D_8008D4C0[][3];
extern FixedMatrix D_800CD250;
extern SdkMatrix D_80126B90[][2];
extern int D_8007D910;

int func_80047D88(RendererDrawState *draw, FixedMatrix *matrix);
void func_8000A910(int angle, int size);
void func_8004E968(ObjectDrawResource *resource, int frame, int duration);

#endif
