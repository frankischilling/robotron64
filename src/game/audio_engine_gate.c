#include "../../include/audio_properties_internal.h"

extern AudioInstance *D_8008D9BC;

void func_80059A88(AudioVoice *voice)
{
    static short D_80192770;
    static unsigned int D_80192774;
    static unsigned char *D_80192778;

    const unsigned char *instanceIndex = &voice->instanceIndex;

    D_80192778 = voice->command[1] + (*instanceIndex + D_8008D9BC)->gates;
    if (*D_80192778) {
        if (*D_80192778 == 255) {
            *D_80192778 = voice->command[2];
        }
        D_80192770 = (voice->command[4] << 8) | voice->command[3];
        if (D_80192770 >= 0 && D_80192770 < voice->labelCount) {
            unsigned int *const *labelOffsets = &voice->labelOffsets;

            D_80192774 = (*labelOffsets)[D_80192770];
            D_80192774 += (unsigned int)voice->data;
            voice->command = (unsigned char *)D_80192774;
            voice->delay = 0;
            voice->commandRedirect = 1;
        }
    }
}
