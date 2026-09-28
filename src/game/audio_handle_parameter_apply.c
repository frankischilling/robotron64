#include "../../include/audio_property_pipeline_internal.h"

void func_800582A8(int handle, int slot, int value,
                   void (*callback)(AudioVoice *, int))
{
    AudioVoice *voice;

    if (func_80052AA8()) {
        func_8005895C();
        voice = func_800564E0(handle, slot);
        if (voice) {
            func_80057858(voice, value, callback);
        }
        func_8005899C();
    }
}
