#include "../../include/audio_backend_internal.h"

void func_8005C7F8(AudioVoice *voice, AudioPatchRegion *region, AudioWaveRecord *wave,
                   unsigned char key, unsigned char velocity)
{
    static unsigned int D_80192B44;
    static int D_80192B48;
    static AudioStatusRecord *D_80192B4C;
    static AudioStatusRecord *D_80192B50;
    static int D_80192B54;
    static unsigned int D_80192B58;

    D_80192B58 = ~0U;
    D_80192B54 = 256;
    D_80192B44 = D_80192820;
    D_80192B4C = D_8019281C;
    D_80192B50 = 0;
    D_80192B48 = 0;
    while (D_80192B44--) {
        if (!D_80192B4C->active) {
            func_8005C334(D_80192B4C, voice, region, wave, key, velocity);
            D_80192B48 = 0;
            break;
        }
        if (region->priority >= D_80192B4C->priority) {
            if (D_80192B4C->priority < D_80192B54) {
                D_80192B48 = 1;
                D_80192B54 = D_80192B4C->priority;
                D_80192B58 = D_80192B4C->time;
                D_80192B50 = D_80192B4C;
            } else if (D_80192B4C->flag40) {
                if (D_80192B50->flag40) {
                    if (D_80192B4C->time < D_80192B58) {
                        D_80192B48 = 1;
                        D_80192B54 = D_80192B4C->priority;
                        D_80192B58 = D_80192B4C->time;
                        D_80192B50 = D_80192B4C;
                    }
                } else {
                    D_80192B48 = 1;
                    D_80192B54 = D_80192B4C->priority;
                    D_80192B58 = D_80192B4C->time;
                    D_80192B50 = D_80192B4C;
                }
            } else if (!D_80192B50->flag40) {
                if (D_80192B4C->time < D_80192B58) {
                    D_80192B48 = 1;
                    D_80192B54 = D_80192B4C->priority;
                    D_80192B58 = D_80192B4C->time;
                    D_80192B50 = D_80192B4C;
                }
            }
        }
        D_80192B4C++;
    }
    if (D_80192B48) {
        func_8005C3E4(D_80192B50);
        func_8005C334(D_80192B50, voice, region, wave, key, velocity);
    }
}
