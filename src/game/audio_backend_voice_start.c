#include "../../include/audio_backend_internal.h"

void func_8005C334(AudioStatusRecord *hardware, AudioVoice *voice, AudioPatchRegion *region,
                   AudioWaveRecord *wave, unsigned char key, unsigned char velocity)
{
    hardware->active = 1;
    hardware->flag40 = 0;
    hardware->flag20 = 1;
    hardware->voiceIndex = voice->index;
    hardware->priority = region->priority;
    hardware->key = key;
    hardware->velocity = velocity;
    hardware->pedalPending = 0;
    hardware->region = region;
    hardware->wave = wave;
    hardware->time = *D_80192828;
    ++voice->hardwareVoiceCount;
    ++D_80192810->activeStatusCount;
    func_8005B064(hardware);
}
