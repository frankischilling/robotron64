#include "../../include/audio_sequence_internal.h"

void func_800538F8(AudioVoice *voice, AudioSequenceTrack *track)
{
    voice->record4C = (void *)track->header->commandBytes;
    voice->record1A = track->header->labelCount;
    voice->data = track->commands;
    voice->command = func_80059580(voice->data, &voice->delay);
    voice->labelOffsets = track->labels;
}
