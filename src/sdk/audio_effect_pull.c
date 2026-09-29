#include "../../include/sdk_audio_reverb.h"

#define SWAP_AUDIO_BUFFERS(input, output) { \
    short temporary = output; \
    output = input; \
    input = temporary; \
}

SdkAudioCommand *func_8006F07C(void *state, short *output, int samples, int offset,
                               SdkAudioCommand *commands)
{
    SdkAudioCommand *next = commands;
    AudioEffect *effect = state;
    AudioFilter *source = effect->filter.source;
    short index, firstBuffer, secondBuffer, inputBuffer, outputBuffer;
    short *inputPosition, *outputPosition, gain, *previousOutput = 0;
    AudioDelay *delay, *previousDelay;

    next = source->handler(source, output, samples, offset, commands);
    inputBuffer = SDK_AUDIO_AUX_LEFT;
    outputBuffer = SDK_AUDIO_AUX_RIGHT;
    firstBuffer = SDK_AUDIO_EFFECT_TEMP_0;
    secondBuffer = SDK_AUDIO_EFFECT_TEMP_1;

    SDK_AUDIO_BUFFER(next++, 0, 0, 0, samples << 1);
    SDK_AUDIO_MIX(next++, 0, 0xDA83, SDK_AUDIO_AUX_LEFT, inputBuffer);
    SDK_AUDIO_MIX(next++, 0, 0x5A82, SDK_AUDIO_AUX_RIGHT, inputBuffer);
    next = func_8006E8D0(effect, effect->input, inputBuffer, samples, next);
    SDK_AUDIO_CLEAR(next++, outputBuffer, samples << 1);

    for (index = 0; index < effect->sectionCount; index++) {
        delay = &effect->delays[index];
        inputPosition = &effect->input[-delay->input];
        outputPosition = &effect->input[-delay->output];
        if (inputPosition == previousOutput) {
            SWAP_AUDIO_BUFFERS(firstBuffer, secondBuffer);
        } else {
            next = func_8006EA58(effect, inputPosition, firstBuffer, samples, next);
        }
        next = func_8006EBE4(effect, delay, secondBuffer, samples, next);
        if (delay->feedForward != 0) {
            SDK_AUDIO_MIX(next++, 0, (unsigned short)delay->feedForward,
                            firstBuffer, secondBuffer);
            if (delay->resampler == 0 && delay->lowPass == 0) {
                next = func_8006E8D0(effect, outputPosition, secondBuffer, samples, next);
            }
        }
        if (delay->feedback != 0) {
            SDK_AUDIO_MIX(next++, 0, (unsigned short)delay->feedback,
                            secondBuffer, firstBuffer);
            next = func_8006E8D0(effect, inputPosition, firstBuffer, samples, next);
        }
        if (delay->lowPass != 0) {
            next = func_8006E818(delay->lowPass, secondBuffer, samples, next);
        }
        if (delay->resampler == 0) {
            next = func_8006E8D0(effect, outputPosition, secondBuffer, samples, next);
        }
        if (delay->gain != 0) {
            SDK_AUDIO_MIX(next++, 0, (unsigned short)delay->gain,
                            secondBuffer, outputBuffer);
        }
        previousOutput = &effect->input[delay->output];
    }

    effect->input += samples;
    if (effect->input > &effect->base[effect->length]) {
        effect->input -= effect->length;
    }
    SDK_AUDIO_DMEM_MOVE(next++, outputBuffer, SDK_AUDIO_AUX_LEFT, samples << 1);
    return next;
}
