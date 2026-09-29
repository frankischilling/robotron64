#include "../../include/audio_property_pipeline_internal.h"

void func_800580D4(AudioVoice *voice, int value)
{
    voice->command[0] = 15;
    voice->command[1] = value;
    D_8008D800[voice->backend]->commands[8](voice);
}
