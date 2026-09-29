#include "../../include/sdk_audio.h"

void func_80066680(AudioSynth *synth, SdkAudioVoice *voice, float pitch)
{
    AudioParameter *parameter;

    if (voice->physical != 0) {
        parameter = func_80065D40();
        if (parameter != 0) {
            parameter->delta = synth->parameterSamples + voice->physical->offset;
            parameter->type = 7;
            parameter->data.floating = pitch;
            parameter->next = 0;
            voice->physical->channel->setParameter(voice->physical->channel, 3,
                                                   parameter);
        }
    }
}
