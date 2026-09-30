#include "../../include/audio_properties_internal.h"

extern unsigned char D_8008D853;
extern AudioInstance *D_8008D9BC;

void func_80059D20(AudioVoice *voice)
{
    static unsigned char D_80192790;
    static unsigned char *D_80192794;

    if (voice->command[1] == 255) {
        D_80192794 = (D_8008D9BC + voice->instanceIndex)->iterations;
        D_80192790 = D_8008D853;
        while (D_80192790--) {
            *D_80192794++ = 255;
        }
    } else {
        int index = voice->command[1];

        D_80192794 = (voice->instanceIndex + D_8008D9BC)->iterations + index;
        *D_80192794 = 255;
    }
}
