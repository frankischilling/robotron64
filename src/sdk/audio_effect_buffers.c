#include "../../include/sdk_audio_reverb.h"

SdkAudioCommand *func_8006EBE4(AudioEffect *effect, AudioDelay *delay, int buffer,
                               int inputSamples, SdkAudioCommand *commands)
{
    SdkAudioCommand *next = commands;
    int pitch;
    int samples;
    int resampleBuffer = SDK_AUDIO_EFFECT_TEMP_2;
    short *output;
    float fractionalSamples;
    float ratio;
    float delta;
    int alignment;
    int length;

    if (delay->resampler != 0) {
        length = delay->output - delay->input;
        delta = func_8006E770(delay, inputSamples);
        delta /= length;
        delta = (int)(delta * 32768);
        delta = delta / 32768;
        ratio = 1.0 - delta;
        fractionalSamples = delay->resampler->delta + ratio * (float)inputSamples;
        samples = (int)fractionalSamples;
        delay->resampler->delta = fractionalSamples - (float)samples;
        output = &effect->input[-(delay->output - delay->resampleDelta)];
        alignment = ((int)output & 7) >> 1;
        next = func_8006EA58(effect, output - alignment, resampleBuffer,
                              samples + alignment, next);
        pitch = (int)(ratio * 32768);
        SDK_AUDIO_BUFFER(next++, 0, resampleBuffer + (alignment << 1), buffer,
                           inputSamples << 1);
        SDK_AUDIO_RESAMPLE(next++, delay->resampler->first, pitch,
                             func_800606A0(delay->resampler->state));
        delay->resampler->first = 0;
        delay->resampleDelta += samples - inputSamples;
    } else {
        output = &effect->input[-delay->output];
        next = func_8006EA58(effect, output, buffer, inputSamples, next);
    }
    return next;
}

SdkAudioCommand *func_8006EA58(AudioEffect *effect, short *position, int buffer,
                               int samples, SdkAudioCommand *commands)
{
    SdkAudioCommand *next = commands;
    int wrappedSamples;
    int remainingSamples;
    short *endPosition;
    short *bufferEnd;

    bufferEnd = effect->base + effect->length;
    if (position < effect->base) {
        position += effect->length;
    }
    endPosition = position + samples;
    if (endPosition > bufferEnd) {
        wrappedSamples = endPosition - bufferEnd;
        remainingSamples = bufferEnd - position;
        SDK_AUDIO_BUFFER(next++, 0, buffer, 0, remainingSamples << 1);
        SDK_AUDIO_LOAD(next++, func_800606A0(position));
        SDK_AUDIO_BUFFER(next++, 0, buffer + (remainingSamples << 1), 0,
                           wrappedSamples << 1);
        SDK_AUDIO_LOAD(next++, func_800606A0(effect->base));
    } else {
        SDK_AUDIO_BUFFER(next++, 0, buffer, 0, samples << 1);
        SDK_AUDIO_LOAD(next++, func_800606A0(position));
    }
    SDK_AUDIO_BUFFER(next++, 0, 0, 0, samples << 1);
    return next;
}

SdkAudioCommand *func_8006E8D0(AudioEffect *effect, short *position, int buffer,
                               int samples, SdkAudioCommand *commands)
{
    SdkAudioCommand *next = commands;
    int wrappedSamples;
    int remainingSamples;
    short *endPosition;
    short *bufferEnd;

    bufferEnd = effect->base + effect->length;
    if (position < effect->base) {
        position += effect->length;
    }
    endPosition = position + samples;
    if (endPosition > bufferEnd) {
        wrappedSamples = endPosition - bufferEnd;
        remainingSamples = bufferEnd - position;
        SDK_AUDIO_BUFFER(next++, 0, 0, buffer, remainingSamples << 1);
        SDK_AUDIO_SAVE(next++, func_800606A0(position));
        SDK_AUDIO_BUFFER(next++, 0, 0, buffer + (remainingSamples << 1),
                           wrappedSamples << 1);
        SDK_AUDIO_SAVE(next++, func_800606A0(effect->base));
        SDK_AUDIO_BUFFER(next++, 0, 0, 0, samples << 1);
    } else {
        SDK_AUDIO_BUFFER(next++, 0, 0, buffer, samples << 1);
        SDK_AUDIO_SAVE(next++, func_800606A0(position));
    }
    return next;
}

SdkAudioCommand *func_8006E818(AudioLowPass *filter, int buffer, int samples,
                               SdkAudioCommand *commands)
{
    SdkAudioCommand *next = commands;

    SDK_AUDIO_BUFFER(next++, 0, buffer, buffer, samples << 1);
    SDK_AUDIO_LOAD_BOOK(next++, 32, func_800606A0(filter->vector.coefficients));
    SDK_AUDIO_POLE(next++, filter->first, filter->gain,
                     func_800606A0(filter->state));
    filter->first = 0;
    return next;
}
