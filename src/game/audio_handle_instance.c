#include "../../include/audio_properties_internal.h"

AudioInstance *func_80056480(int handle)
{
    AudioInstance *instance;

    if (handle > 0 && D_8008D844 >= (unsigned int)handle) {
        instance = &D_801902EC->instances[(unsigned char)(handle - 1)];
        if (instance->flag40) {
            return instance;
        }
    }
    return 0;
}
