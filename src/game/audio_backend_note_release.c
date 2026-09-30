#include "../../include/audio_backend_internal.h"

void func_8005CBB4(AudioVoice *voice)
{
    static int D_80192B70;
    static AudioStatusRecord *D_80192B74;

    D_80192B74 = D_8019281C;
    D_80192B70 = D_80192820;
    while (D_80192B70--) {
        if (D_80192B74->active && !D_80192B74->flag40 &&
            voice->command[1] == (*D_80192B74).key &&
            D_80192B74->voiceIndex == voice->index) {
            if (voice->pedalReleased) {
                func_8005C5BC(D_80192B74);
            } else {
                D_80192B74->pedalPending = 1;
            }
        }
        ++D_80192B74;
    }
}
