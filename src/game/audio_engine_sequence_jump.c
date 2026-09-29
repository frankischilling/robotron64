#include "../../include/audio_properties_internal.h"

extern AudioVoice *D_8008D9B8;
extern AudioInstance *D_8008D9BC;
extern AudioContext *D_8008D9C0;

void func_8005A180(AudioVoice *voice)
{
    static short D_801927C4;
    static short D_801927C6;
    static unsigned int D_801927C8;
    static unsigned char D_801927CC;
    static unsigned char *D_801927D0;
    static AudioVoice *D_801927D4;
    static AudioInstance *D_801927D8;

    D_801927C4 = (voice->command[2] << 8) | voice->command[1];
    if (D_801927C4 >= 0 && D_801927C4 < voice->labelCount) {
        D_801927D8 = &D_8008D9BC[voice->instanceIndex];
        D_801927C6 = D_8008D9C0->table->slots[D_801927D8->index].voiceIndexCount;
        D_801927CC = D_801927D8->voiceCount;
        D_801927D0 = D_801927D8->voiceIndices;
        while (D_801927C6--) {
            if (*D_801927D0 != 255) {
                D_801927D4 = &D_8008D9B8[*D_801927D0];
                D_801927C8 = D_801927D4->labelOffsets[D_801927C4];
                D_801927C8 += (unsigned int)D_801927D4->data;
                D_801927D4->command = (unsigned char *)D_801927C8;
                D_801927D4->delay = 0;
                D_801927D4->commandRedirect = 1;
                if (!--D_801927CC) {
                    break;
                }
            }
            D_801927D0++;
        }
    }
}
