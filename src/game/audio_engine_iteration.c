#include "../../include/audio_properties_internal.h"

extern AudioInstance *D_8008D9BC;

void func_80059B68(AudioVoice *voice)
{
    static short D_8019277C;
    static unsigned int D_80192780;
    static unsigned char *D_80192784;

    const unsigned char *instanceIndex = &voice->instanceIndex;

    D_80192784 = voice->command[1] + (*instanceIndex + D_8008D9BC)->iterations;
    if (*D_80192784) {
        if (*D_80192784 == 255) {
            *D_80192784 = voice->command[2];
        } else {
            --*D_80192784;
        }
        D_8019277C = (voice->command[4] << 8) | voice->command[3];
        if (D_8019277C >= 0 && D_8019277C < voice->labelCount) {
            unsigned int *const *labelOffsets = &voice->labelOffsets;

            D_80192780 = (*labelOffsets)[D_8019277C];
            D_80192780 += (unsigned int)voice->data;
            voice->command = (unsigned char *)D_80192780;
            voice->delay = 0;
            voice->commandRedirect = 1;
        }
    }
}
