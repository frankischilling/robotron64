#include "audio_properties_internal.h"

void func_80055D58(int ownerTag, int useArgument, int argument)
{
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;

    if (func_80052AA8()) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active) {
            while (remaining--) {
                if (instance->active) {
                    if (ownerTag == instance->ownerTag) {
                        instance->flag08 = 1;
                        instance->flag20 = 0;
                        instance->flag10 = 0;
                    }
                    if (!--active) {
                        break;
                    }
                }
                instance++;
            }
        }
        if (useArgument) {
            func_800592F0(14);
            func_80059348(&argument, 4);
        } else {
            func_800592F0(10);
        }
        func_80059348(&ownerTag, 4);
        func_8005899C();
    }
}
