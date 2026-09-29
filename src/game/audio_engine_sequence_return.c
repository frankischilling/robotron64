#include "../../include/audio_properties_internal.h"

extern AudioVoice *D_8008D9B8;
extern AudioInstance *D_8008D9BC;
extern AudioContext *D_8008D9C0;

void func_8005A310(AudioVoice *voice)
{
    static short D_801927DC;
    static unsigned char D_801927DE;
    static unsigned char *D_801927E0;
    static AudioVoice *D_801927E4;
    static AudioInstance *D_801927E8;

    D_801927E8 = &D_8008D9BC[voice->instanceIndex];
    D_801927DC = D_8008D9C0->table->slots[D_801927E8->index].voiceIndexCount;
    D_801927DE = D_801927E8->voiceCount;
    D_801927E0 = D_801927E8->voiceIndices;
    while (D_801927DC--) {
        if (*D_801927E0 != 255) {
            D_801927E4 = &D_8008D9B8[*D_801927E0];
            D_801927E4->command = *--D_801927E4->returnStack;
            D_801927E4->delay = 0;
            D_801927E4->commandRedirect = 1;
            if (!--D_801927DE) {
                break;
            }
        }
        D_801927E0++;
    }
}
