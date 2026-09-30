#include "../../include/audio_properties_internal.h"

extern unsigned int D_8008D848;
extern unsigned char D_8008D9B4;
extern AudioVoice *D_8008D9B8;
extern AudioInstance *D_8008D9BC;
extern AudioContext *D_8008D9C0;

void func_800596C4(AudioContext *context)
{
    D_8008D9C0 = context;
    D_8008D9B8 = D_8008D9C0->voices;
    D_8008D9BC = D_8008D9C0->instances;
    D_8008D9B4 = D_8008D848;
}

void func_800596FC(AudioContext *context)
{
}

void func_80059704(AudioVoice *voice)
{
}

void func_8005970C(AudioVoice *voice)
{
}

void func_80059714(AudioVoice *voice)
{
}
