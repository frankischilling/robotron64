#include "../../include/audio_callbacks.h"

AudioDmaCallback func_8005254C(void)
{
    if (D_801901E0.initialized == 0) {
        D_801901E0.active = 0;
        D_801901E0.free = D_801901EC;
        D_801901E0.initialized = 1;
    }
    return func_80052378;
}
