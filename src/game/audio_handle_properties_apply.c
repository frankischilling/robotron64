#include "../../include/audio_properties_internal.h"

void func_80056A54(int handle, AudioProperties *properties)
{
    AudioInstance *instance;
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
                    func_8005789C(&D_801902EC->voices[*indices], properties);
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
