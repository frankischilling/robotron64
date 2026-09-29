#include "../../include/audio_properties_internal.h"

void func_8005A6D8(AudioVoice *voice)
{
    voice->property16 = (voice->command[2] << 8) | voice->command[1];
    voice->property1C = func_800589E4(func_800589DC(), voice->property14,
                                    voice->property16);
}
