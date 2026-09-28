#include "../../include/audio_properties_internal.h"

AudioVoice *func_800564E0(int handle, int slot)
{
    AudioInstance *instance;
    AudioVoice *voice;
    int index;

    if (handle > 0 && D_8008D844 >= (unsigned int)handle) {
        instance = &D_801902EC->instances[(unsigned char)(handle - 1)];
        if (instance->flag40) {
            index = instance->voiceIndices[slot];
            if (index != 255) {
                voice = index + D_801902EC->voices;
                if (voice->flag20) {
                    return voice;
                }
            }
        }
    }
    return 0;
}
