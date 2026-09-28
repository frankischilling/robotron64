#include "../../include/audio_properties_internal.h"

void func_80057858(AudioVoice *voice, int value, void (*callback)(AudioVoice *, int))
{
    unsigned char *savedCommand;

    savedCommand = voice->command;
    voice->command = D_80190300;
    callback(voice, value);
    voice->command = savedCommand;
}
