#include "../../include/audio_properties_internal.h"

void func_80057F74(AudioVoice *voice, int value)
{
    voice->command[0] = 11;
    voice->command[1] = value;
    D_8008D800[voice->backend]->command2C(voice);
}
