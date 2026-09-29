#include "../../include/sdk_audio.h"

AudioSynth *D_8008F160 = 0;

void func_80065B04(AudioSynth *synth)
{
    if (D_8008F160 != 0) {
        func_8006B5A0(synth);
        D_8008F160 = 0;
    }
}

void func_80065B3C(AudioSynth *synth, SdkAudioSynthConfig *configuration)
{
    if (D_8008F160 == 0) {
        D_8008F160 = synth;
        func_80066010(synth, configuration);
    }
}
