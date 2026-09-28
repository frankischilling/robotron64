#include "../../include/audio_commands.h"

extern unsigned int D_8008D844;

int func_80053CC0(int index)
{
    int result;
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;
    AudioContext *context;

    if (func_80052ACC(index) == 0) {
        return 0;
    }
    result = 1;
    func_8005895C();
    context = D_801902EC;
    remaining = D_8008D844;
    active = context->activeCount;
    instance = context->instances;
    if (active != 0) {
        while (remaining--) {
            if (instance->active) {
                if (index == instance->index) {
                    if (instance->state == 0) {
                        result = 2;
                    } else if (instance->state == 1) {
                        result = 3;
                    }
                }
                if (--active == 0) {
                    break;
                }
            }
            instance++;
        }
    }
    func_8005899C();
    return result;
}
