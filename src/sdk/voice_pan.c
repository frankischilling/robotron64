#include "../../include/sdk_audio.h"

void func_800667B0(AudioSynth *synth, SdkAudioVoice *voice, unsigned char pan)
{
    AudioParameter *parameter;

    if (voice->physical != 0) {
        parameter = func_80065D40();
        if (parameter != 0) {
            parameter->delta = synth->parameterSamples + voice->physical->offset;
            parameter->type = 12;
            parameter->data.integer = pan;
            parameter->next = 0;
            voice->physical->channel->setParameter(voice->physical->channel, 3,
                                                   parameter);
        }
    }
}
