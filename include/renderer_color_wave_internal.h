#ifndef ROBOTRON_RENDERER_COLOR_WAVE_INTERNAL_H
#define ROBOTRON_RENDERER_COLOR_WAVE_INTERNAL_H

#include "renderer_color_gradient_internal.h"

/* The grid renderers update three channels in each 16-byte wave record. */
typedef struct RendererColorWave {
    unsigned char color[3];
    unsigned char unknown03;
    unsigned char amplitude[3];
    unsigned char unknown07;
    unsigned char frequency[3];
    unsigned char unknown0B;
    unsigned char phase[3];
    unsigned char unknown0F;
} RendererColorWave;

typedef char RendererColorWaveMustBe16Bytes[
    sizeof(RendererColorWave) == 16 ? 1 : -1];

typedef struct RendererColorWaveState {
    int time;
    RendererColorWave waves[16];
} RendererColorWaveState;

typedef char RendererColorWaveStateMustBe260Bytes[
    sizeof(RendererColorWaveState) == 260 ? 1 : -1];
typedef char RendererColorWaveArrayMustStartAt4[
    (unsigned int)&((RendererColorWaveState *)0)->waves == 4 ? 1 : -1];

extern RendererColorWaveState D_800CD2B4;
#define D_800CD2B8 (D_800CD2B4.waves)

extern int D_8007CCB0;
void func_800400D0(void);
void func_800414C4(int red, int green, int blue);
void func_80041B24(int r1, int g1, int b1, int r2, int g2, int b2);

#endif
