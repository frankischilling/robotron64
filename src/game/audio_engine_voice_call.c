#include "../../include/audio_properties_internal.h"

extern unsigned char D_8008D8D0[];

void func_8005A73C(AudioVoice *voice)
{
    short label;
    unsigned int position;

    label = (voice->command[2] << 8) | voice->command[1];
    if (label >= 0 && label < voice->labelCount) {
        *voice->returnStack++ = D_8008D8D0[26] + voice->command;
        position = voice->labelOffsets[label];
        position += (unsigned int)voice->data;
        voice->command = (unsigned char *)position;
        voice->delay = 0;
        voice->commandRedirect = 1;
    }
}
