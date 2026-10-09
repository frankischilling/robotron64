#include "../../include/graphics_state_internal.h"

#include "../../include/renderer_peak_metrics.h"

void func_8004CCD0(void)
{
    int index = D_800C8DFC;
    RendererPeakMetrics *metrics;

    if (index < 0) index = 0;
    /* Retail permits index 201, beyond the 201 records cleared at startup.
     * Its FPS field aliases the heap pointer; retain the original limit. */
    if (index >= 202) index = 201;
    metrics = &D_8013DC30[index];
    index = D_8013D9C0 - D_8013D9C4;
    if (metrics->renderBufferBytes < index) metrics->renderBufferBytes = index;
    index = D_80138250;
    if (metrics->framesPerSecond < index) metrics->framesPerSecond = index;
    index = D_80123B18;
    if (metrics->primitives < index) metrics->primitives = index;
    index = D_8007D6A8;
    if (metrics->matrices < index) metrics->matrices = index;
    index = D_80126B84 - D_80123B20;
    if (metrics->vertices < index) metrics->vertices = index;
}
