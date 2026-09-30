#include "audio_properties_internal.h"

void func_800555CC(int notify)
{
    int remaining;
    int active;
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    int slots;
    int voices;

    if (func_80052AA8()) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active) {
            while (remaining--) {
                if (instance->active && instance->flag10) {
                    instance->flag10 = 0;
                    voices = instance->voiceCount;
                    indices = instance->voiceIndices;
                    slots = D_801902EC->voiceIndexCount;
                    while (slots--) {
                        if (*indices != 255) {
                            voice = &D_801902EC->voices[*indices];
                            func_80054C50(voice, instance);
                            if (notify) {
                                func_8005ADD0(instance->index, *indices, voice);
                            }
                            if (!--voices) {
                                break;
                            }
                        }
                        indices++;
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
