#ifndef ROBOTRON_SDK_AUDIO_EFFECT_H
#define ROBOTRON_SDK_AUDIO_EFFECT_H

#include "sdk_audio_pipeline.h"
#include "sdk_audio_commands.h"

typedef short AudioPoleState[4];

typedef struct AudioLowPass {
    short frequency;
    short gain;
    union {
        short coefficients[16];
        long long alignment;
    } vector;
    AudioPoleState *state;
    int first;
} AudioLowPass;

struct AudioDelay {
    unsigned int input;
    unsigned int output;
    short feedForward;
    short feedback;
    short gain;
    float resampleIncrement;
    float resampleValue;
    int resampleDelta;
    float resampleGain;
    AudioLowPass *lowPass;
    AudioResampler *resampler;
};

enum SdkAudioEffectType {
    SDK_AUDIO_EFFECT_NONE,
    SDK_AUDIO_EFFECT_SMALL_ROOM,
    SDK_AUDIO_EFFECT_BIG_ROOM,
    SDK_AUDIO_EFFECT_CHORUS,
    SDK_AUDIO_EFFECT_FLANGE,
    SDK_AUDIO_EFFECT_ECHO,
    SDK_AUDIO_EFFECT_CUSTOM
};

typedef char AudioPoleStateMustBe8Bytes[sizeof(AudioPoleState) == 8 ? 1 : -1];
typedef char AudioLowPassMustBe48Bytes[sizeof(AudioLowPass) == 48 ? 1 : -1];
typedef char AudioDelayMustBe40Bytes[sizeof(AudioDelay) == 40 ? 1 : -1];

void func_8006B8A0(AudioLowPass *filter);
void func_8006B940(AudioEffect *effect, SdkAudioSynthConfig *configuration,
                   AudioHeap *heap);
int func_8006EE08(void *state, int parameter, void *value);
int func_8006F064(void *state, int parameter, void *value);
SdkAudioCommand *func_8006F07C(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands);

#endif
