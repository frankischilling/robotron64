#include "../../include/sdk_audio.h"

void func_80066710(AudioSynth *synth, SdkAudioVoice *voice, short volume, int time)
{
    AudioParameter *parameter;

    if (voice->physical != 0) {
        parameter = func_80065D40();
        if (parameter != 0) {
            parameter->delta = synth->parameterSamples + voice->physical->offset;
            parameter->type = 11;
            parameter->data.integer = volume;
            parameter->more.integer = func_80065C38(synth, time);
            parameter->next = 0;
            voice->physical->channel->setParameter(voice->physical->channel, 3,
                                                   parameter);
        }
    }
}
