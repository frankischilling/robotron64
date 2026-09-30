#ifndef ROBOTRON_SDK_AUDIO_REVERB_H
#define ROBOTRON_SDK_AUDIO_REVERB_H

#include "sdk_audio_effect.h"
#include "sdk_audio_decoder.h"
#include "sdk_io.h"

enum SdkAudioEffectBuffer {
    SDK_AUDIO_EFFECT_TEMP_0 = 0x000,
    SDK_AUDIO_EFFECT_TEMP_1 = 0x140,
    SDK_AUDIO_EFFECT_TEMP_2 = 0x280
};

#define SDK_AUDIO_POLE(cursor, flags, gain, state) \
    SDK_AUDIO_PACKET(cursor, 0x0E000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF) | \
        SDK_AUDIO_FIELD(gain, 0, 0xFFFF), state)

float func_8006E770(AudioDelay *delay, int samples);
SdkAudioCommand *func_8006E818(AudioLowPass *filter, int buffer, int samples,
                               SdkAudioCommand *commands);
SdkAudioCommand *func_8006E8D0(AudioEffect *effect, short *position, int buffer,
                               int samples, SdkAudioCommand *commands);
SdkAudioCommand *func_8006EA58(AudioEffect *effect, short *position, int buffer,
                               int samples, SdkAudioCommand *commands);
SdkAudioCommand *func_8006EBE4(AudioEffect *effect, AudioDelay *delay, int buffer,
                               int inputSamples, SdkAudioCommand *commands);

#endif
