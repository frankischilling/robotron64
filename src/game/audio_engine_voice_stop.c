#include "../../include/audio_properties_internal.h"

extern AudioContext *D_8008D9C0;

void func_8005971C(AudioVoice *voice)
{
    static AudioInstance *D_80192758;
    static unsigned char *D_8019275C;
    static int D_80192760;

    D_80192758 = &D_8008D9C0->instances[voice->instanceIndex];
    if (!voice->paused) {
        voice->paused = 1;
        if (!--D_80192758->runningVoiceCount) {
            D_80192758->state = 0;
        }
    }
    if (!voice->flag20) {
        D_80192760 = D_8008D9C0->voiceIndexCount;
        D_8019275C = D_80192758->voiceIndices;
        while (D_80192760--) {
            if (voice->index == *D_8019275C) {
                *D_8019275C = 255;
                D_8019275C++;
                break;
            }
            D_8019275C++;
        }
        voice->flag80 = 0;
        D_8008D9C0->activeVoiceCount--;
        D_80192758->voiceCount--;
        if (!D_80192758->voiceCount) {
            D_80192758->active = 0;
            D_8008D9C0->activeCount--;
        }
    }
    voice->flag08 = 0;
}
