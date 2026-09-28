#include "../../include/audio_properties_internal.h"

void func_800576E0(AudioVoice *voice, int value)
{
    voice->command[0] = 7;
    voice->command[1] = value & 255;
    voice->command[2] = value >> 8;
    D_8008D800[voice->backend]->command1C(voice);
}

void func_80057744(AudioVoice *voice, int value)
{
    voice->command[0] = 9;
    voice->command[1] = value & 255;
    voice->command[2] = value >> 8;
    D_8008D800[voice->backend]->command24(voice);
}

void func_800577A8(AudioVoice *voice, int value)
{
    voice->command[0] = 12;
    voice->command[1] = value;
    D_8008D800[voice->backend]->updateVoice(voice);
}

void func_80057800(AudioVoice *voice, int value)
{
    voice->command[0] = 13;
    voice->command[1] = value;
    D_8008D800[voice->backend]->command34(voice);
}
