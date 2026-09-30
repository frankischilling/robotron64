#include "../../include/audio_properties_internal.h"

void func_80056648(int handle)
{
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    int slots;
    int voices;

    if (func_80052AA8()) {
        func_8005895C();
        instance = func_80056480(handle);
        if (instance) {
            voices = instance->voiceCount;
            slots = D_801902EC->voiceIndexCount;
            indices = instance->voiceIndices;
            while (slots--) {
                if (*indices != 255) {
                    voice = &D_801902EC->voices[*indices];
                    voice->flag20 = 0;
                    D_8008D800[voice->backend]->stopVoice(voice);
                    if (!--voices) {
                        break;
                    }
                }
                indices++;
            }
            instance->flag40 = 0;
        }
        func_8005899C();
    }
}
