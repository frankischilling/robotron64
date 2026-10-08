#include "../../include/actor_resource_internal.h"

void func_8001D260(void)
{
    int i;

    for (i = 0; i < 244; i++) {
        D_800B1BE8[i].flags06.bits.loaded = 0;
    }
    for (i = 0; i < 36; i++) {
        D_800AF1F0[i].flags06.bits.loaded = 0;
    }
    for (i = 0; i < 8; i++) {
        D_800ACE58[i].flags06.bits.loaded = 0;
    }
    for (i = 0; i < 16; i++) {
        D_800B1BE8[i].flags06.bits.loaded = 0;
    }
    for (i = 0; i < 11; i++) {
        D_800AC998[i].flags06.bits.loaded = 0;
    }
    for (i = 0; i < 16; i++) {
        D_8009AA00[i].flags06.bits.loaded = 0;
    }
    D_8009B138.flags06.bits.loaded = 0;
    for (i = 0; i < 4; i++) {
        D_8009AFD8[i].flags06.bits.loaded = 0;
    }
    for (i = 0; i < 5; i++) {
        D_8009EA18[0].resources[i].resource.flags06.bits.loaded = 0;
    }
}
