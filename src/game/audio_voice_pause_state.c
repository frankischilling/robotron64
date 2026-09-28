#include "audio_properties_internal.h"

void func_80054C50(AudioVoice *voice, AudioInstance *instance)
{
    if (voice->paused) {
        voice->flag40 = 0;
        voice->paused = 0;
        if (++instance->runningVoiceCount) {
            instance->state = 1;
        }
    }
}

void func_80054CA0(AudioVoice *voice, AudioInstance *instance)
{
    if (!voice->paused) {
        voice->flag40 = 1;
        voice->paused = 1;
        if (!--instance->runningVoiceCount) {
            instance->state = 0;
        }
    }
}
