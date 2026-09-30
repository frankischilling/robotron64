#include "../../include/audio_backend_internal.h"

void func_8005C1D8(AudioVoice *voice)
{
    static int D_80192B28;
    static int D_80192B2C;
    static AudioStatusRecord *D_80192B30;
    static unsigned char D_80192B34;

    D_80192B34 = voice->command[1];
    if (voice->unknown0C == D_80192B34) {
        return;
    }
    voice->unknown0C = D_80192B34;
    D_80192B28 = voice->hardwareVoiceCount;
    if (D_80192B28 != 0) {
        D_80192B30 = D_8019281C;
        D_80192B2C = D_80192820;
        while (D_80192B2C--) {
            if (D_80192B30->active && D_80192B30->voiceIndex == voice->index) {
                func_800667B0(D_8008F160, &D_80190200[D_80192B30->index], D_80192B34);
                if (--D_80192B28 == 0) {
                    break;
                }
            }
            D_80192B30++;
        }
    }
}
