#include "../../include/renderer_geometry_internal.h"

void func_8004417C(int light)
{
    if (light != D_80123ADC) {
        D_80123ADC = light;
        FRAME_COMMAND(0x03860010, &D_80123B28[D_80123ADC]);
    }
}
