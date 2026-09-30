#include "../../include/audio_properties_internal.h"

unsigned int func_80057358(int handle, unsigned int amount)
{
    unsigned int position;
    AudioInstance *instance;
    unsigned char *command;
    AudioVoice *voice;
    unsigned char *indices;
    int slots;
    int voices;

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
            if (*indices != 255) {
                voice = *indices + D_801902EC->voices;
                D_8008D800[voice->backend]->pauseVoice(voice);
                position = voice->position28 + amount;
                func_80056EF0(voice, position, &command);
                if (!--voices) {
                    break;
                }
            }
            indices++;
        }
    }
    func_8005899C();
    return func_80057610(handle);
}
