#include "../../include/audio_property_pipeline_internal.h"

void func_80058158(AudioVoice *voice, int value)
{
    voice->command[0] = 16;
    voice->command[1] = value;
    D_8008D800[voice->backend]->command40(voice);
}
