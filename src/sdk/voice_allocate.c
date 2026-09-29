#include "../../include/sdk_audio.h"

int func_80066448(AudioSynth *synth, SdkAudioVoice *voice,
                  SdkAudioVoiceConfig *configuration)
{
    AudioPhysicalVoice *physical = 0;
    AudioFilter *channel;
    AudioParameter *parameter;
    int stolen;

    voice->priority = configuration->priority;
    voice->unityPitch = configuration->unityPitch;
    voice->table = 0;
    voice->effectBus = configuration->effectBus;
    voice->state = 0;
    voice->physical = 0;
    stolen = func_80066360(synth, &physical, configuration->priority);
    if (physical) {
        channel = physical->channel;
        if (stolen != 0) {
            physical->offset = 512;
            physical->voice->physical = 0;
            parameter = func_80065D40();
            parameter->delta = synth->parameterSamples;
            parameter->type = 11;
            parameter->data.integer = 0;
            parameter->more.integer = physical->offset - 64;
            channel->setParameter(channel, 3, parameter);
            parameter = func_80065D40();
            if (parameter != 0) {
                parameter->delta = synth->parameterSamples + physical->offset;
                parameter->type = 15;
                parameter->next = 0;
                channel->setParameter(channel, 3, parameter);
            }
        } else {
            physical->offset = 0;
        }
        physical->voice = voice;
        voice->physical = physical;
    }
    return physical != 0;
}

int func_80066360(AudioSynth *synth, AudioPhysicalVoice **result, short priority)
{
    AudioLink *link;
    AudioPhysicalVoice *physical;
    int stolen = 0;

    if ((link = synth->pendingFreeVoices.next) != 0) {
        *result = (AudioPhysicalVoice *)link;
        func_80065AB0(link);
        func_80065AE0(link, &synth->allocatedVoices);
    } else if ((link = synth->freeVoices.next) != 0) {
        *result = (AudioPhysicalVoice *)link;
        func_80065AB0(link);
        func_80065AE0(link, &synth->allocatedVoices);
    } else {
        for (link = synth->allocatedVoices.next; link != 0; link = link->next) {
            physical = (AudioPhysicalVoice *)link;
            if (physical->voice->priority <= priority && physical->offset == 0) {
                *result = physical;
                priority = physical->voice->priority;
                stolen = 1;
            }
        }
    }
    return stolen;
}
