#include "audio_properties_internal.h"

int func_80055C6C(int index)
{
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;
    int state;

    if (!func_80052AA8()) {
        return 1;
    }
    state = 1;
    func_8005895C();
    remaining = D_8008D844;
    active = D_801902EC->activeCount;
    instance = D_801902EC->instances;
    if (active) {
        while (remaining--) {
            if (instance->active) {
                if (index == instance->ownerTag) {
                    if (instance->state == 0) {
                        state = 2;
                    } else if (instance->state == 1) {
                        state = 3;
                    }
                }
                if (!--active) {
                    break;
                }
            }
            instance++;
        }
    }
    func_8005899C();
    return state;
}
