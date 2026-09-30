#include "audio_properties_internal.h"

void func_8005530C(int useArgument, int argument)
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
        if (useArgument == 1) {
            func_8005AD94(argument);
        }
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active) {
            while (remaining--) {
                if (instance->active && instance->flag20) {
                    instance->flag20 = 0;
                    voices = instance->voiceCount;
                    indices = instance->voiceIndices;
                    slots = D_801902EC->voiceIndexCount;
                    while (slots--) {
                        if (*indices != 255) {
                            voice = &D_801902EC->voices[*indices];
                            if (useArgument == 1) {
                                D_8008D800[voice->backend]->pauseVoice(voice);
                            }
                            func_80054CA0(voice, instance);
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
        if (useArgument == 1) {
            func_8005ADC4();
        }
        func_8005899C();
    }
}
