#include "../../include/audio_property_pipeline_internal.h"

void func_80058050(AudioVoice *voice, int value)
{
    voice->command[0] = 14;
    voice->command[1] = value;
    D_8008D800[voice->backend]->commands[7](voice);
}
