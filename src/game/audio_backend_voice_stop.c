#include "../../include/audio_backend_internal.h"

void func_8005B7BC(AudioVoice *voice)
{
    static AudioInstance *D_80192ACC;

    D_80192ACC = &D_80192814[voice->instanceIndex];
    func_8005B854(voice);
    if (voice->hardwareVoiceCount) {
        voice->paused = 1;
        if (!--D_80192ACC->runningVoiceCount) {
            D_80192ACC->state = 0;
        }
    } else {
        func_8005971C(voice);
    }
}
