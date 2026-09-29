#include "../../include/sdk_audio.h"

void func_80066970(AudioSynth *synth, SdkAudioVoice *voice, short priority)
{
    voice->priority = priority;
}
