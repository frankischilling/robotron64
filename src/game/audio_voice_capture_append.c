#include "../../include/audio_voice_capture_internal.h"

void func_8005AEA8(AudioVoice *voice, short instanceIndex, short voiceIndex,
                   unsigned char first, unsigned char second,
                   void *record, int value)
{
    if (D_8008DA2C != 0 &&
        ((voice->category == 1 && (D_8008DA2C->categoryMask & 1)) ||
         (voice->category == 0 && (D_8008DA2C->categoryMask & 2)))) {
        if (D_8008DA2C->count < 32) {
            D_8008DA2C->voices[D_8008DA2C->count].instanceIndex = instanceIndex;
            D_8008DA2C->voices[D_8008DA2C->count].voiceIndex = voiceIndex;
            D_8008DA2C->voices[D_8008DA2C->count].first = first;
            D_8008DA2C->voices[D_8008DA2C->count].second = second;
            D_8008DA2C->voices[D_8008DA2C->count].record = record;
            D_8008DA2C->voices[D_8008DA2C->count].value = value;
            D_8008DA2C->count++;
        }
    }
}
