#include "../../include/audio_properties_internal.h"

void func_80056C58(int handle, short rate)
{
    int value;
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    int slots;
    int voices;

    if (func_80052AA8()) {
        value = 0;
        func_8005895C();
        instance = func_80056480(handle);
        if (instance) {
            voices = instance->voiceCount;
            slots = D_801902EC->voiceIndexCount;
            indices = instance->voiceIndices;
            while (slots--) {
                if (*indices != 255) {
                    voice = &D_801902EC->voices[*indices];
                    voice->property16 = rate;
                    if (!value) {
                        value = func_800589E4(func_800589DC(), voice->property14,
                                             (short)voice->property16);
                    }
                    voice->property1C = value;
                    if (!--voices) {
                        break;
                    }
                }
                indices++;
            }
        }
        func_8005899C();
    }
}
