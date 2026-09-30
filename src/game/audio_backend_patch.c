#include "../../include/audio_properties_internal.h"

void func_8005B9F8(AudioVoice *voice)
{
    static short D_80192AE0;

    D_80192AE0 = (voice->command[2] << 8) | voice->command[1];
    voice->property04 = D_80192AE0;
}

void func_8005BA1C(AudioVoice *voice)
{
}
