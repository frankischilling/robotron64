#include "../../include/sdk_audio.h"

void func_800668C0(AudioSynth *synth, SdkAudioVoice *voice)
{
    AudioFreeParameter *parameter;

    if (voice->physical != 0) {
        if (voice->physical->offset != 0) {
            parameter = (AudioFreeParameter *)func_80065D40();
            if (parameter == 0) {
                return;
            }
            parameter->delta = synth->parameterSamples + voice->physical->offset;
            parameter->type = 0;
            parameter->physical = voice->physical;
            voice->physical->channel->setParameter(voice->physical->channel, 3,
                                                   parameter);
        } else {
            func_80065C90(synth, voice->physical);
        }
        voice->physical = 0;
    }
}
