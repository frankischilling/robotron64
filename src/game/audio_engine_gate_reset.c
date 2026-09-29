#include "../../include/audio_properties_internal.h"

extern unsigned char D_8008D84F;
extern AudioInstance *D_8008D9BC;

void func_80059C54(AudioVoice *voice)
{
    static unsigned char D_80192788;
    static unsigned char *D_8019278C;

    if (voice->command[1] == 255) {
        D_8019278C = (D_8008D9BC + voice->instanceIndex)->gates;
        D_80192788 = D_8008D84F;
        while (D_80192788--) {
            *D_8019278C++ = 255;
        }
    } else {
        int index = voice->command[1];

        D_8019278C = (voice->instanceIndex + D_8008D9BC)->gates + index;
        *D_8019278C = 255;
    }
}
