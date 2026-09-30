#include "../../include/audio_backend_internal.h"

void func_8005BCC8(AudioVoice *voice)
{
}

void func_8005BCD0(AudioVoice *voice)
{
}

void func_8005BCD8(AudioVoice *voice)
{
    static int D_80192AFC;
    static int D_80192B00;
    static unsigned int D_80192B04;
    static AudioStatusRecord *D_80192B08;
    static unsigned char D_80192B0C;

    D_80192B0C = voice->command[1];
    if (voice->parameter0D == D_80192B0C) {
        return;
    }
    voice->parameter0D = D_80192B0C;
    D_80192AFC = voice->hardwareVoiceCount;
    if (D_80192AFC) {
        D_80192B00 = D_80192820;
        D_80192B08 = D_8019281C;
        while (D_80192B00--) {
            if (D_80192B08->active && D_80192B08->voiceIndex == voice->index) {
                if (voice->category == 0) {
                    D_80192B04 = (unsigned int)(D_80192B08->velocity * D_80192B08->region->volume *
                                                voice->parameter0D * D_8008DA1C) >> 13;
                } else {
                    D_80192B04 = (unsigned int)(D_80192B08->velocity * D_80192B08->region->volume *
                                                voice->parameter0D * D_8008DA20) >> 13;
                }
                func_80066710(D_8008F160, &D_80190200[D_80192B08->index], (short)D_80192B04, 1000);
                if (!--D_80192AFC) {
                    break;
                }
            }
            D_80192B08++;
        }
    }
}
