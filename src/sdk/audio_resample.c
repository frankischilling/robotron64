#include "../../include/sdk_audio_pipeline.h"
#include "../../include/sdk_io.h"
#include "../../include/sdk_audio_mix_commands.h"

#define AUDIO_PITCH_SCALE 32768.0f
#define AUDIO_MAXIMUM_RATIO 1.99996

SdkAudioCommand *func_8006CBAC(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    AudioResampler *resampler = state;
    SdkAudioCommand *cursor = commands;
    short input;
    int inputSamples;
    AudioFilter *source = resampler->filter.source;
    int pitch;
    float required;

    input = SDK_AUDIO_DECODER_OUTPUT;
    if (samples == 0) {
        return cursor;
    }
    if (resampler->unityPitch != 0) {
        cursor = source->handler(source, &input, samples, offset, commands);
        SDK_AUDIO_DMEM_MOVE(cursor++, input, *output, samples * 2);
    } else {
        if (resampler->ratio > AUDIO_MAXIMUM_RATIO) {
            resampler->ratio = AUDIO_MAXIMUM_RATIO;
        }
        resampler->ratio = (int)(resampler->ratio * AUDIO_PITCH_SCALE);
        resampler->ratio = resampler->ratio / AUDIO_PITCH_SCALE;
        required = resampler->delta + resampler->ratio * samples;
        inputSamples = (int)required;
        resampler->delta = required - inputSamples;
        cursor = source->handler(source, &input, inputSamples, offset, commands);
        pitch = (int)(resampler->ratio * AUDIO_PITCH_SCALE);
        SDK_AUDIO_BUFFER(cursor++, 0, input, *output, samples * 2);
        SDK_AUDIO_RESAMPLE(cursor++, resampler->first, pitch,
                           func_800606A0(resampler->state));
        resampler->first = 0;
    }
    return cursor;
}

int func_8006CAC0(void *state, int parameter, void *value)
{
    AudioFilter *base = state;
    AudioResampler *resampler = state;
    union {
        float value;
        int bits;
    } pitch;

    switch (parameter) {
    case SDK_AUDIO_SET_SOURCE:
        base->source = value;
        break;
    case SDK_AUDIO_RESET:
        resampler->delta = 0.0f;
        resampler->first = 1;
        resampler->motion = 0;
        resampler->unityPitch = 0;
        if (base->source != 0) {
            base->source->setParameter(base->source, SDK_AUDIO_RESET, 0);
        }
        break;
    case SDK_AUDIO_START:
        resampler->motion = 1;
        if (base->source != 0) {
            base->source->setParameter(base->source, SDK_AUDIO_START, 0);
        }
        break;
    case SDK_AUDIO_SET_PITCH:
        pitch.bits = (int)value;
        resampler->ratio = pitch.value;
        break;
    case SDK_AUDIO_SET_UNITY_PITCH:
        resampler->unityPitch = 1;
        break;
    default:
        if (base->source != 0) {
            base->source->setParameter(base->source, parameter, value);
        }
        break;
    }
    return 0;
}
