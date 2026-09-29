#include "../../include/audio_properties_internal.h"

void func_80057EF0(AudioVoice *voice, int value)
{
    voice->command[0] = 10;
    voice->command[1] = value;
    D_8008D800[voice->backend]->commands[3](voice);
}
