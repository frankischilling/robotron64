#include "../../include/audio_properties_internal.h"

void func_8005789C(AudioVoice *voice, AudioProperties *properties)
{
    unsigned int fields;

    voice->flag08 = 0;
    voice->flag04 = 0;
    if (properties && properties->fields) {
        fields = properties->fields;
        if (fields & 1) {
            voice->parameter0D = properties->parameter04;
            func_80057858(voice, properties->parameter04, func_800577A8);
            if (!(fields &= ~1)) {
                return;
            }
        }
        if (fields & 2) {
            voice->parameter0E = properties->parameter05;
            func_80057858(voice, properties->parameter05, func_80057800);
            if (!(fields &= ~2)) {
                return;
            }
        }
        if (fields & 4) {
            voice->property04 = properties->parameter06;
            func_80057858(voice, properties->parameter06, func_800576E0);
            if (!(fields &= ~4)) {
                return;
            }
        }
        if (fields & 8) {
            voice->property06 = properties->parameter08;
            func_80057858(voice, properties->parameter08, func_80057744);
            if (!(fields &= ~8)) {
                return;
            }
        }
        if (fields & 16) {
            if (voice->controlMask & (1 << properties->parameter0A)) {
                voice->flag40 = 1;
                D_8008D800[voice->backend]->pauseVoice(voice);
            } else {
                voice->flag40 = 0;
            }
            if (!(fields &= ~16)) {
                return;
            }
        }
        if (fields & 32) {
            voice->property16 = properties->parameter0C;
            voice->property1C = func_800589E4(func_800589DC(), voice->property14,
                                            (short)voice->property16);
            if (!(fields &= ~32)) {
                return;
            }
        }
        if (fields & 64) {
            voice->position2C = voice->position28 + properties->offset10;
            voice->flag08 = 1;
            if (!(fields &= ~64)) {
                return;
            }
        }
        if (fields & 128) {
            voice->flag04 = 1;
        }
    }
}
