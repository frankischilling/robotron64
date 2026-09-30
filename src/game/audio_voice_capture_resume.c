#include "../../include/audio_voice_capture_internal.h"

void func_8005ADD0(short instanceIndex, unsigned char voiceIndex, AudioVoice *voice)
{
    int index;

    for (index = 0; index < D_80192890.count; index++) {
        if (voiceIndex == D_80192890.voices[index].voiceIndex &&
            instanceIndex == D_80192890.voices[index].instanceIndex) {
            if (D_80192890.voices[index].region != 0) {
                func_8005C7F8(voice, D_80192890.voices[index].region,
                    D_80192890.voices[index].wave,
                    D_80192890.voices[index].key,
                    D_80192890.voices[index].velocity);
                D_80192890.voices[index].region = 0;
            }
        }
    }
}
