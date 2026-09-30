#include "../../include/audio_properties_internal.h"

extern unsigned char D_8008D8D0[];
extern AudioVoice *D_8008D9B8;
extern AudioInstance *D_8008D9BC;
extern AudioContext *D_8008D9C0;

void func_80059FC8(AudioVoice *voice)
{
    static short D_801927AC;
    static short D_801927AE;
    static unsigned int D_801927B0;
    static unsigned char D_801927B4;
    static unsigned char *D_801927B8;
    static AudioVoice *D_801927BC;
    static AudioInstance *D_801927C0;

    D_801927AC = (voice->command[2] << 8) | voice->command[1];
    if (D_801927AC >= 0 && D_801927AC < voice->labelCount) {
        D_801927C0 = &D_8008D9BC[voice->instanceIndex];
        D_801927AE = D_8008D9C0->table->slots[D_801927C0->index].voiceIndexCount;
        D_801927B4 = D_801927C0->voiceCount;
        D_801927B8 = D_801927C0->voiceIndices;
        while (D_801927AE--) {
            if (*D_801927B8 != 255) {
                D_801927BC = &D_8008D9B8[*D_801927B8];
                *D_801927BC->returnStack++ = D_8008D8D0[26] + D_801927BC->command;
                D_801927B0 = D_801927BC->labelOffsets[D_801927AC];
                D_801927B0 += (unsigned int)D_801927BC->data;
                D_801927BC->command = (unsigned char *)D_801927B0;
                D_801927BC->delay = 0;
                D_801927BC->commandRedirect = 1;
                if (!--D_801927B4) {
                    break;
                }
            }
            D_801927B8++;
        }
    }
}
