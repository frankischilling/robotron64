#include "../../include/audio_properties_internal.h"

unsigned int func_80057610(int handle)
{
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    unsigned char index;
    int slots;
    int voices;
    unsigned int maximum;

    maximum = 0;
    if (!func_80052AA8()) {
        return 0;
    }
    func_8005895C();
    instance = func_80056480(handle);
    if (instance) {
        voices = instance->voiceCount;
        slots = D_801902EC->voiceIndexCount;
        indices = instance->voiceIndices;
        while (slots--) {
            index = *indices++;
            if (index != 255) {
                voice = index + D_801902EC->voices;
                if (maximum < (unsigned int)voice->position28) {
                    maximum = voice->position28;
                }
                if (!--voices) {
                    break;
                }
            }
        }
    }
    func_8005899C();
    return maximum;
}
