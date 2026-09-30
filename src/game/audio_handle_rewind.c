#include "../../include/audio_properties_internal.h"

int func_80056DB0(int handle)
{
    AudioInstance *instance;
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
                voice = &D_801902EC->voices[*indices];
                D_8008D800[voice->backend]->pauseVoice(voice);
                voice->unknown20 = 0;
                voice->position28 = 0;
                voice->command = func_80059580(voice->data, &voice->delay);
                if (!--voices) {
                    break;
                }
            }
            indices++;
        }
    }
    func_8005899C();
    return 0;
}
