#include "../../include/audio_backend_internal.h"

void func_8005C684(AudioStatusRecord *voice)
{
    static unsigned int D_80192B3C;
    static AudioVoice *D_80192B40;

    D_80192B40 = &D_80192818[voice->voiceIndex];
    if (D_80192B40->category == 0) {
        D_80192B3C = (unsigned int)(voice->velocity * voice->region->volume *
                                    D_80192B40->parameter0D * D_8008DA1C) >> 13;
    } else {
        D_80192B3C = (unsigned int)(voice->velocity * voice->region->volume *
                                    D_80192B40->parameter0D * D_8008DA20) >> 13;
    }
    D_80192B3C = (unsigned int)(voice->region->decayVolume * D_80192B3C) >> 7;
    if (D_8008D860) {
        func_80066710(D_8008F160, &D_80190200[voice->index], (short)D_80192B3C,
                      voice->region->decayTime * 1000);
    }
    voice->flag20 = 0;
}
