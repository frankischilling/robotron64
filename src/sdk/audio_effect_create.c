#include "../../include/sdk_audio_effect.h"

/* The preset delay unit rounds 44.1 samples down to a multiple of eight. */
#define EFFECT_DELAY(milliseconds) ((milliseconds) * (((int)44.1f) & ~7))

static int smallRoomParameters[26] = {
    3, EFFECT_DELAY(100),
    0, EFFECT_DELAY(54), 9830, -9830, 0, 0, 0, 0,
    EFFECT_DELAY(19), EFFECT_DELAY(38), 3276, -3276, 0x3FFF, 0, 0, 0,
    0, EFFECT_DELAY(60), 5000, 0, 0, 0, 0, 0x5000
};

static int bigRoomParameters[34] = {
    4, EFFECT_DELAY(100),
    0, EFFECT_DELAY(66), 9830, -9830, 0, 0, 0, 0,
    EFFECT_DELAY(22), EFFECT_DELAY(54), 3276, -3276, 0x3FFF, 0, 0, 0,
    EFFECT_DELAY(66), EFFECT_DELAY(91), 3276, -3276, 0x3FFF, 0, 0, 0,
    0, EFFECT_DELAY(94), 8000, 0, 0, 0, 0, 0x5000
};

static int echoParameters[10] = {
    1, EFFECT_DELAY(200),
    0, EFFECT_DELAY(179), 12000, 0, 0x7FFF, 0, 0, 0
};

static int chorusParameters[10] = {
    1, EFFECT_DELAY(20),
    0, EFFECT_DELAY(5), 0x4000, 0, 0x7FFF, 7600, 700, 0
};

static int flangeParameters[10] = {
    1, EFFECT_DELAY(20),
    0, EFFECT_DELAY(5), 0, 0x5FFF, 0x7FFF, 380, 500, 0
};

static int nullParameters[10] = {
    0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
};

void func_8006B940(AudioEffect *effect, SdkAudioSynthConfig *configuration,
                   AudioHeap *heap)
{
    unsigned short section, nextParameter, sample;
    int *parameters = 0;
    AudioFilter *filter = &effect->filter;
    AudioDelay *delay;

    func_8006E750(filter, 0, func_8006F064, 5);
    filter->handler = func_8006F07C;
    effect->parameterHandler = func_8006EE08;
    switch (configuration->effectType) {
    case SDK_AUDIO_EFFECT_SMALL_ROOM:
        parameters = smallRoomParameters;
        break;
    case SDK_AUDIO_EFFECT_BIG_ROOM:
        parameters = bigRoomParameters;
        break;
    case SDK_AUDIO_EFFECT_ECHO:
        parameters = echoParameters;
        break;
    case SDK_AUDIO_EFFECT_CHORUS:
        parameters = chorusParameters;
        break;
    case SDK_AUDIO_EFFECT_FLANGE:
        parameters = flangeParameters;
        break;
    case SDK_AUDIO_EFFECT_CUSTOM:
        parameters = configuration->parameters;
        break;
    default:
        parameters = nullParameters;
        break;
    }

    nextParameter = 0;
    effect->sectionCount = parameters[nextParameter++];
    effect->length = parameters[nextParameter++];
    effect->delays = func_80065730(0, 0, heap, effect->sectionCount, sizeof(AudioDelay));
    effect->base = func_80065730(0, 0, heap, effect->length, sizeof(short));
    effect->input = effect->base;
    for (sample = 0; sample < effect->length; sample++) {
        effect->base[sample] = 0;
    }

    for (section = 0; section < effect->sectionCount; section++) {
        delay = &effect->delays[section];
        delay->input = parameters[nextParameter++];
        delay->output = parameters[nextParameter++];
        delay->feedback = parameters[nextParameter++];
        delay->feedForward = parameters[nextParameter++];
        delay->gain = parameters[nextParameter++];
        if (parameters[nextParameter]) {
            delay->resampleIncrement =
                (((float)parameters[nextParameter++] / 1000) * 2.0) / configuration->outputRate;
            delay->resampleGain =
                ((float)parameters[nextParameter++] / 173123.404906676) *
                (delay->output - delay->input);
            delay->resampleValue = 1.0f;
            delay->resampleDelta = 0.0;
            delay->resampler = func_80065730(0, 0, heap, 1, sizeof(AudioResampler));
            delay->resampler->state = func_80065730(0, 0, heap, 1, sizeof(AudioResampleState));
            delay->resampler->delta = 0.0f;
            delay->resampler->first = 1;
        } else {
            delay->resampler = 0;
            nextParameter++;
            nextParameter++;
        }
        if (parameters[nextParameter]) {
            delay->lowPass = func_80065730(0, 0, heap, 1, sizeof(AudioLowPass));
            delay->lowPass->state = func_80065730(0, 0, heap, 1, sizeof(AudioPoleState));
            delay->lowPass->frequency = parameters[nextParameter++];
            func_8006B8A0(delay->lowPass);
        } else {
            delay->lowPass = 0;
            nextParameter++;
        }
    }
}
