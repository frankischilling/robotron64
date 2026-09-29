#include "../../include/audio_properties_internal.h"

void func_8005A7C4(AudioVoice *voice)
{
    short label;
    unsigned int position;

    label = (voice->command[2] << 8) | voice->command[1];
    if (label >= 0 && label < voice->labelCount) {
        position = voice->labelOffsets[label];
        position += (unsigned int)voice->data;
        voice->command = (unsigned char *)position;
        voice->delay = 0;
        voice->commandRedirect = 1;
    }
}
