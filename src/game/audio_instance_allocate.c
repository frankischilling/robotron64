#include "../../include/audio_sequence_internal.h"

extern unsigned int D_8008D848;
void func_800538F8(AudioVoice *voice, AudioSequenceTrack *track);

int func_8005396C(AudioRecordSlot *slot, int index, int value,
                  int flags, int argument)
{
    AudioVoice *voice;
    AudioSequenceTrack *track;
    AudioInstance *instance;
    unsigned char *indices;
    unsigned char instanceIndex;
    unsigned char voiceIndex;
    unsigned char trackIndex;
    short remaining;
    unsigned char capacity;

    if (!func_80052ACC(index)) {
        return 0;
    }
    func_8005895C();
    capacity = D_8008D844;
    for (instanceIndex = 0; instanceIndex < capacity; instanceIndex++) {
        if (!D_801902EC->instances[instanceIndex].active) {
            break;
        }
    }
    if (instanceIndex == capacity) {
        func_8005899C();
        return 0;
    }
    instance = &D_801902EC->instances[instanceIndex];
    capacity = D_8008D848;
    remaining = slot->voiceIndexCount;
    indices = instance->voiceIndices;
    trackIndex = 0;
    for (voiceIndex = 0; voiceIndex < capacity; voiceIndex++) {
        if (!(D_801902EC->voices + voiceIndex)->flag80) {
            voice = D_801902EC->voices + voiceIndex;
            track = &((AudioSequenceTrack *)slot->value)[trackIndex];
            voice->instanceIndex = instanceIndex;
            func_8005362C(voice, track, (AudioProperties *)argument);
            func_800538F8(voice, track);
            if (flags) {
                voice->flag20 = 1;
                voice->paused = 1;
            } else {
                voice->flag20 = 0;
                voice->paused = 0;
                instance->runningVoiceCount++;
            }
            instance->voiceCount++;
            D_801902EC->activeVoiceCount++;
            *indices++ = voiceIndex;
            trackIndex++;
            if (!--remaining) {
                break;
            }
        }
    }
    if (trackIndex) {
        instance->index = index;
        instance->ownerTag = value;
        if (flags) {
            instance->state = 0;
            instance->flag40 = 1;
        } else {
            instance->flag40 = 0;
            instance->state = 1;
        }
        instance->unknown06[0] = 128;
        instance->unknown06[1] = 64;
        instance->active = 1;
        D_801902EC->activeCount++;
    }
    func_8005899C();
    if (trackIndex) {
        return instanceIndex + 1;
    }
    return 0;
}
