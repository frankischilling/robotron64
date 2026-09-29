#include "../../include/sdk_audio_effect.h"

AudioEffect *func_8006BD80(AudioSynth *synth, short bus,
                           SdkAudioSynthConfig *configuration, AudioHeap *heap)
{
    func_8006B940(&synth->auxiliaryBus[bus].effects[0], configuration, heap);
    func_8006F064(&synth->auxiliaryBus[bus].effects[0], SDK_AUDIO_SET_SOURCE,
                  &synth->auxiliaryBus[bus]);
    func_8006BE20(synth->mainBus, SDK_AUDIO_ADD_SOURCE,
                  &synth->auxiliaryBus[bus].effects[0]);
    return &synth->auxiliaryBus[bus].effects[0];
}
