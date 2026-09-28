#include "../../include/audio_commands.h"

extern unsigned int D_8008D844;

void func_80054178(int useArgument, int argument)
{
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;

    if (func_80052AA8() != 0) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active != 0) {
            while (remaining--) {
                if (instance->active) {
                    instance->flag08 = 1;
                    instance->flag20 = 0;
                    instance->flag10 = 0;
                    if (--active == 0) {
                        break;
                    }
                }
                instance++;
            }
        }
        if (useArgument) {
            func_800592F0(12);
            func_80059348(&argument, 4);
        } else {
            func_800592F0(0);
        }
        func_8005899C();
    }
}
