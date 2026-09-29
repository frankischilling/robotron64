#include "../../include/audio_properties_internal.h"

void func_8005A88C(AudioVoice *voice)
{
    if (!voice->flag20) {
        if (voice->flag04 && (unsigned int)voice->position28 >= 16) {
            voice->commandRedirect = 1;
            voice->command = voice->data;
            voice->command = func_80059580(voice->command, &voice->delay);
        } else {
            D_8008D800[voice->backend]->stopVoice(voice);
        }
    } else {
        if (voice->flag04 && (unsigned int)voice->position28 >= 16) {
            voice->commandRedirect = 1;
            voice->command = voice->data;
            voice->command = func_80059580(voice->command, &voice->delay);
        } else {
            D_8008D800[voice->backend]->stopVoice(voice);
            voice->commandRedirect = 1;
        }
    }
}

void func_8005A9A4(AudioVoice *voice)
{
}
