#include "../../include/audio_properties_internal.h"

int func_800562D4(int ownerTag)
{
    int remaining;
    int active;
    AudioInstance *instance;
    int count;
    int queryOwnerTag;

    queryOwnerTag = ownerTag;
    if (!func_80052AA8()) {
        return 0;
    }
    count = 0;
    func_8005895C();
    remaining = D_8008D844;
    active = D_801902EC->activeCount;
    instance = D_801902EC->instances;
    if (active) {
        while (remaining--) {
            if (instance->active) {
                if (instance->ownerTag == queryOwnerTag) {
                    count++;
                }
                if (!--active) {
                    break;
                }
            }
            instance++;
        }
    }
    func_8005899C();
    return count;
}
