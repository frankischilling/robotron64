#include "audio_properties_internal.h"

void func_80054DF8(int index, int update)
{
    int remaining;
    int active;
    AudioInstance *instance;
    AudioVoice *voice;
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
                    if (index == instance->index && instance->flag20) {
                        instance->flag20 = 0;
                        voices = instance->voiceCount;
                        indices = instance->voiceIndices;
                        slots = D_801902EC->voiceIndexCount;
                        while (slots--) {
                            if (*indices != 255) {
                                voice = &D_801902EC->voices[*indices];
                                func_80054CA0(voice, instance);
                                if (update == 1) {
                                    D_8008D800[voice->backend]->pauseVoice(voice);
                                }
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
