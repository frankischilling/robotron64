#include "audio_properties_internal.h"

void func_80055214(int index, int update)
{
    int remaining;
    int active;
    AudioInstance *instance;

    if (func_80052AA8()) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active) {
            while (remaining--) {
                if (instance->active) {
                    instance->flag20 = 1;
                    if (!--active) {
                        break;
                    }
                }
                instance++;
            }
        }
        func_800592F0(8);
        func_80059348(&index, 4);
        func_80059348(&update, 4);
        func_8005899C();
    }
}
