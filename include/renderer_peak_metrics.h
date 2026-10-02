#ifndef ROBOTRON_RENDERER_PEAK_METRICS_H
#define ROBOTRON_RENDERER_PEAK_METRICS_H

#include "resource_arena.h"

typedef struct RendererPeakMetrics {
    int primitives;
    int vertices;
    int renderBufferBytes;
    int framesPerSecond;
    int matrices;
} RendererPeakMetrics;

typedef char RendererPeakMetricsMustBe20Bytes[
    sizeof(RendererPeakMetrics) == 20 ? 1 : -1];

extern int D_800C8DFC;
extern int D_80138250;
extern RendererPeakMetrics D_8013DC30[];

void func_8004CCD0(void);

#endif
