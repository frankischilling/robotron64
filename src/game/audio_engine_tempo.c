#include "../../include/audio_properties_internal.h"

extern AudioVoice *D_8008D9B8;
extern AudioInstance *D_8008D9BC;
extern AudioContext *D_8008D9C0;

void func_80059E2C(AudioVoice *voice)
{
    static short D_8019279C;
    static unsigned char D_8019279E;
    static unsigned char *D_801927A0;
    static AudioVoice *D_801927A4;
    static AudioInstance *D_801927A8;

    D_801927A8 = D_8008D9BC + voice->instanceIndex;
    D_8019279C = D_8008D9C0->table->slots[D_801927A8->index].voiceIndexCount;
    D_8019279E = D_801927A8->voiceCount;
    D_801927A0 = D_801927A8->voiceIndices;
    while (D_8019279C--) {
        if (*D_801927A0 != 255) {
            D_801927A4 = D_8008D9B8 + *D_801927A0;
            D_801927A4->property16 = (voice->command[2] << 8) | voice->command[1];
            D_801927A4->property1C = func_800589E4(func_800589DC(),
                D_801927A4->property14, D_801927A4->property16);
            if (!--D_8019279E) {
                break;
            }
        }
        D_801927A0++;
    }
}
