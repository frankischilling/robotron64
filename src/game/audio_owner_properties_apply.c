#include "audio_properties_internal.h"

void func_80055AE8(int ownerTag, AudioProperties *properties)
{
    unsigned char remaining;
    unsigned char active;
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
                if (instance->active) {
                    if (ownerTag == instance->ownerTag) {
                        voices = instance->voiceCount;
                        indices = instance->voiceIndices;
                        slots = D_801902EC->voiceIndexCount;
                        while (slots--) {
                            if (*indices != 255) {
                                voice = &D_801902EC->voices[*indices];
                                if (properties) {
                                    func_800557FC(voice, properties);
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
