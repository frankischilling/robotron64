#include "../../include/audio_backend_internal.h"

void func_8005C3E4(AudioStatusRecord *status)
{
    static AudioVoice *D_80192B38;

    func_80066840(D_8008F160, &D_80190200[status->index]);
    func_800668C0(D_8008F160, &D_80190200[status->index]);
    D_80192B38 = &D_80192818[status->voiceIndex];
    D_80192810->activeStatusCount--;
    D_80192B38->hardwareVoiceCount--;
    if (D_80192B38->hardwareVoiceCount == 0 &&
        D_80192B38->paused && !D_80192B38->flag40) {
        func_8005971C(D_80192B38);
    }
    status->active = 0;
    status->flag40 = 0;
    status->flag20 = 0;
}
