#include "../../include/audio_backend_internal.h"

void func_8005C4F8(AudioStatusRecord *voice, int releaseTime)
{
    func_80066970(D_8008F160, &D_80190200[voice->index], 0);
    func_80066710(D_8008F160, &D_80190200[voice->index], 0, releaseTime * 1000);
    voice->flag40 = 1;
    voice->flag20 = 0;
    voice->time = *D_80192828 + releaseTime;
}

void func_8005C5BC(AudioStatusRecord *voice)
{
    func_80066970(D_8008F160, &D_80190200[voice->index], 0);
    func_80066710(D_8008F160, &D_80190200[voice->index], 0, voice->region->releaseTime * 1000);
    voice->flag40 = 1;
    voice->flag20 = 0;
    voice->time = *D_80192828 + voice->region->releaseTime;
}
