#include "../../include/audio_properties_internal.h"

void func_8005A830(AudioVoice *voice)
{
    voice->command = *--voice->returnStack;
    voice->command = func_80059580(voice->command, &voice->delay);
    voice->delay = 0;
    voice->commandRedirect = 1;
}
