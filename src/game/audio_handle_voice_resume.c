#include "../../include/audio_properties_internal.h"

void func_800568B8(int handle, int slot, AudioProperties *properties)
{
    AudioInstance *instance;
    AudioVoice *voice;

    if (func_80052AA8()) {
        func_8005895C();
        instance = func_80056480(handle);
        if (instance) {
            voice = func_800564E0(handle, slot);
            if (voice) {
                func_80054C50(voice, instance);
                func_8005789C(voice, properties);
            }
        }
        func_8005899C();
    }
}
