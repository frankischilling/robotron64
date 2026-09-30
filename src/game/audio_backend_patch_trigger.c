#include "../../include/audio_backend_internal.h"
#include "../../include/audio_patch_table_internal.h"

void func_8005CA34(AudioVoice *voice)
{
    static int D_80192B5C;
    static unsigned char D_80192B60;
    static unsigned char D_80192B61;
    static unsigned char D_80192B62;
    static AudioPatchRecord *D_80192B64;
    static AudioPatchRegion *D_80192B68;
    static AudioWaveRecord *D_80192B6C;

    D_80192B60 = voice->command[1];
    D_80192B61 = voice->command[2];
    D_80192B64 = &D_8019282C[voice->property04];
    D_80192B62 = D_80192B64->regionCount;
    D_80192B5C = 0;
    while (D_80192B62--) {
        D_80192B68 = &D_80192830[D_80192B64->firstRegion + D_80192B5C];
        D_80192B6C = &D_80192834[D_80192B68->waveIndex];
        if (D_80192B60 >= D_80192B68->keyMin &&
            D_80192B60 <= D_80192B68->keyMax) {
            func_8005C7F8(voice, D_80192B68, D_80192B6C, D_80192B60, D_80192B61);
        }
        D_80192B5C++;
    }
}
