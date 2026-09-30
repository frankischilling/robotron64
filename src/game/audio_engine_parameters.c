#include "../../include/audio_properties_internal.h"

extern unsigned char D_80192764;
extern short D_80192766;
extern unsigned char D_80192768;
extern unsigned char D_80192769;

void func_80059898(AudioVoice *voice)
{
}

void func_800598A0(AudioVoice *voice)
{
    D_80192764 = voice->property04 =
        (unsigned char)((voice->command[2] << 8) | voice->command[1]);
}

void func_800598C8(AudioVoice *voice)
{
}

void func_800598D0(AudioVoice *voice)
{
    D_80192766 = voice->property06 =
        (voice->command[2] << 8) | voice->command[1];
}

void func_800598F4(AudioVoice *voice)
{
}

void func_800598FC(AudioVoice *voice)
{
}

void func_80059904(AudioVoice *voice)
{
    D_80192768 = voice->parameter0D = voice->command[1];
}

void func_80059920(AudioVoice *voice)
{
    D_80192769 = voice->parameter0E = voice->command[1];
}

void func_8005993C(AudioVoice *voice)
{
}

void func_80059944(AudioVoice *voice)
{
}

void func_8005994C(AudioVoice *voice)
{
}

void func_80059954(AudioVoice *voice)
{
}

void func_8005995C(AudioVoice *voice)
{
}
