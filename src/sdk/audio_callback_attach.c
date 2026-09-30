#include "../../include/sdk_audio.h"

unsigned int func_800651F0(unsigned int mask);

void func_80066310(AudioSynth *synth, AudioCallbackState *state)
{
    unsigned int mask;

    mask = func_800651F0(1);
    state->field10 = synth->currentSamples;
    state->next = synth->head;
    synth->head = state;
    func_800651F0(mask);
}
