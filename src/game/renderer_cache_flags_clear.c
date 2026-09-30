#include "../../include/resource_bridge_internal.h"
#include "../../include/renderer_peak_metrics.h"

void func_8004BC8C(void)
{
    int i;

    func_8001D260();
    for (i = 0; i < 400; i++) {
        ((ResourceBridgeModelCacheEntry *)(D_80078274 + 0x14))[i].loaded = 0;
    }
    for (i = 0; i < 400; i++) {
        ((ResourceBridgeAnimationCacheEntry *)(D_80078274 + 0x1F5C))[i].loaded = 0;
    }
    D_8013D9C0 = D_8013D9C4;
}
