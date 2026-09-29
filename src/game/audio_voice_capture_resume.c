#include "../../include/audio_voice_capture_internal.h"

void func_8005ADD0(short instanceIndex, unsigned char voiceIndex, AudioVoice *voice)
{
    int index;

    for (index = 0; index < D_80192890.count; index++) {
        if (voiceIndex == D_80192890.voices[index].voiceIndex &&
            instanceIndex == D_80192890.voices[index].instanceIndex) {
            if (D_80192890.voices[index].record != 0) {
                func_8005C7F8(voice, D_80192890.voices[index].record,
                    D_80192890.voices[index].value,
                    D_80192890.voices[index].first,
                    D_80192890.voices[index].second);
                D_80192890.voices[index].record = 0;
            }
        }
    }
}
