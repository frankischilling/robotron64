#include "../../include/audio_backend_internal.h"

void func_8005BEFC(AudioVoice *voice)
{
    static unsigned int D_80192B10;
    static unsigned int D_80192B14;
    static AudioStatusRecord *D_80192B18;
    static short D_80192B1C;
    static unsigned char D_80192B1E;

    D_80192B1E = voice->command[1];
    if (voice->parameter0E == D_80192B1E) {
        return;
    }
    voice->parameter0E = D_80192B1E;
    if (D_8008DA24) {
        D_80192B10 = voice->hardwareVoiceCount;
        if (D_80192B10) {
            D_80192B14 = D_80192820;
            D_80192B18 = D_8019281C;
            while (D_80192B14--) {
                if (D_80192B18->active && D_80192B18->voiceIndex == voice->index) {
                    D_80192B1C = voice->parameter0E + D_80192B18->region->pan - 64;
                    if (D_80192B1C >= 128) {
                        D_80192B1C = 127;
                    }
                    if (D_80192B1C < 0) {
                        D_80192B1C = 0;
                    }
                    func_800667B0(D_8008F160, &D_80190200[D_80192B18->index], (unsigned char)D_80192B1C);
                    if (!--D_80192B10) {
                        break;
                    }
                }
                D_80192B18++;
            }
        }
    }
}

void func_8005C0A0(AudioVoice *voice)
{
    static unsigned char D_80192B1F;
    static unsigned char D_80192B20;
    static AudioStatusRecord *D_80192B24;

    if (voice->command[1] == 0) {
        voice->pedalReleased = 1;
        D_80192B1F = voice->hardwareVoiceCount;
        if (D_80192B1F) {
            D_80192B24 = D_8019281C;
            D_80192B20 = D_80192820;
            while (D_80192B20--) {
                if (D_80192B24->active && !D_80192B24->flag40 &&
                    D_80192B24->voiceIndex == voice->index && D_80192B24->pedalPending) {
                    D_80192B24->pedalPending = 0;
                    func_8005C5BC(D_80192B24);
                    if (!--D_80192B1F) {
                        break;
                    }
                }
                D_80192B24++;
            }
        }
    } else {
        voice->pedalReleased = 0;
    }
}
