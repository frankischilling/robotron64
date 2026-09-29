#include "../../include/audio_properties_internal.h"

int func_8005638C(int *ownerTags)
{
    int remaining;
    int active;
    AudioInstance *instance;
    int slot, count, found;
    int *list;
    int *output;

    output = ownerTags;
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
            found = 0;
            if (instance->active) {
                slot = 0;
                if (count > 0) {
                    list = output;
                    do {
                        if (instance->ownerTag == *list) {
                            found = 1;
                            break;
                        }
                        list++;
                        slot++;
                    } while (slot != count);
                }
                if (!found) {
                    output[count++] = instance->ownerTag;
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
