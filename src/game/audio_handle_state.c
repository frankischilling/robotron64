#include "../../include/audio_properties_internal.h"

int func_800565D8(int handle)
{
    AudioInstance *instance;
    int state;

    if (!func_80052AA8()) {
        return 0;
    }
    state = 0;
    instance = func_80056480(handle);
    if (instance) {
        if (instance->state == 0) {
            state = 1;
        } else if (instance->state == 1) {
            state = 2;
        }
    }
    return state;
}
