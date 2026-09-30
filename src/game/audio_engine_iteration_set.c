#include "../../include/audio_properties_internal.h"

extern AudioInstance *D_8008D9BC;

void func_80059DEC(AudioVoice *voice)
{
    const unsigned char *instanceIndex;
    static unsigned char *D_80192798;

    instanceIndex = &voice->instanceIndex;
    D_80192798 = voice->command[1] + (*instanceIndex + D_8008D9BC)->iterations;
    *D_80192798 = voice->command[2];
}
