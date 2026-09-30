#include "../../include/audio_properties_internal.h"

extern AudioVoice *D_8008D9B8;
extern AudioContext *D_8008D9C0;

void func_8005A448(AudioVoice *voice)
{
    static AudioInstance *D_801927EC;
    static AudioVoice *D_801927F0;
    static unsigned char *D_801927F4;
    static int D_801927F8;
    static int D_801927FC;

    if (!voice->flag20) {
        D_801927EC = &D_8008D9C0->instances[voice->instanceIndex];
        D_801927FC = D_8008D9C0->voiceIndexCount;
        D_801927F8 = D_801927EC->voiceCount;
        D_801927F4 = D_801927EC->voiceIndices;
        while (D_801927FC--) {
            if (*D_801927F4 != 255) {
                D_801927F0 = &D_8008D9B8[*D_801927F4];
                D_8008D800[D_801927F0->backend]->stopVoice(D_801927F0);
                if (!--D_801927F8) {
                    break;
                }
            }
            D_801927F4++;
        }
    } else {
        D_801927EC = &D_8008D9C0->instances[voice->instanceIndex];
        D_801927FC = D_8008D9C0->voiceIndexCount;
        D_801927F8 = D_801927EC->voiceCount;
        D_801927F4 = D_801927EC->voiceIndices;
        while (D_801927FC--) {
            if (*D_801927F4 != 255) {
                D_801927F0 = &D_8008D9B8[*D_801927F4];
                D_8008D800[D_801927F0->backend]->stopVoice(D_801927F0);
                if (!--D_801927F8) {
                    break;
                }
            }
            D_801927F4++;
        }
        voice->commandRedirect = 1;
    }
}
