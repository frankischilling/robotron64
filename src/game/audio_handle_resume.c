#include "../../include/audio_properties_internal.h"

void func_80056780(int handle, AudioProperties *properties)
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
                    func_80054C50(voice, instance);
                    func_8005789C(voice, properties);
                    if (!--voices) {
                        break;
                    }
                }
                indices++;
            }
            instance->state = 1;
        }
        func_8005899C();
    }
}
