#include "../../include/audio_properties_internal.h"

void func_80057E3C(AudioVoice *voice, int value)
{
    voice->command[0] = 18;
    voice->command[1] = value;
    D_8008D800[voice->backend]->commands[11](voice);
}
