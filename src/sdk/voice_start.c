#include "../../include/sdk_audio.h"

void func_80066590(AudioSynth *synth, SdkAudioVoice *voice, AudioWaveTable *wave,
                   float pitch, short volume, unsigned char pan,
                   unsigned char effect, int attackTime)
{
    AudioStartParameter *parameter;

    if (voice->physical != 0) {
        parameter = (AudioStartParameter *)func_80065D40();
        if (parameter != 0) {
            if (effect < 0) {
                effect = -effect;
            }
            parameter->delta = synth->parameterSamples + voice->physical->offset;
            parameter->next = 0;
            parameter->type = 13;
            parameter->unity = voice->unityPitch;
            parameter->pan = pan;
            parameter->volume = volume;
            parameter->effectMix = effect;
            parameter->pitch = pitch;
            parameter->samples = func_80065C38(synth, attackTime);
            parameter->wave = wave;
            voice->physical->channel->setParameter(voice->physical->channel, 3,
                                                   parameter);
        }
    }
}
