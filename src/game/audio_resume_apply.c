#include "audio_properties_internal.h"

void func_800550AC(int index)
{
    int remaining;
    int active;
    AudioInstance *instance;
    unsigned char *indices;
    int slots;
    int voices;

    if (func_80052ACC(index)) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active) {
            while (remaining--) {
                if (instance->active) {
                    if (index == instance->index && instance->flag10) {
                        instance->flag10 = 0;
                        voices = instance->voiceCount;
                        indices = instance->voiceIndices;
                        slots = D_801902EC->voiceIndexCount;
                        while (slots--) {
                            if (*indices != 255) {
                                func_80054C50(&D_801902EC->voices[*indices], instance);
                                if (!--voices) {
                                    break;
                                }
                            }
                            indices++;
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
    }
}
