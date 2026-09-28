#include "../../include/audio_properties_internal.h"

void func_80057B08(AudioVoice *voice, AudioProperties *properties)
{
    unsigned int fields;

    if (properties->fields) {
        fields = properties->fields;
        if (fields & 1) {
            properties->parameter04 = voice->parameter0D;
            if (!(fields &= ~1)) {
                return;
            }
        }
        if (fields & 2) {
            properties->parameter05 = voice->parameter0E;
            if (!(fields &= ~2)) {
                return;
            }
        }
        if (fields & 4) {
            properties->parameter06 = voice->property04;
            if (!(fields &= ~4)) {
                return;
            }
        }
        if (fields & 8) {
            properties->parameter08 = voice->property06;
            if (!(fields &= ~8)) {
                return;
            }
        }
        if (fields & 16) {
            properties->parameter0A = voice->controlMask;
            if (!(fields &= ~16)) {
                return;
            }
        }
        if (fields & 32) {
            properties->parameter0C = voice->property16;
            if (!(fields &= ~32)) {
                return;
            }
        }
        if (fields & 64) {
            if (!voice->flag08) {
                properties->fields &= ~64;
            } else {
                properties->offset10 = voice->position2C - voice->position28;
            }
            if (!(fields &= ~64)) {
                return;
            }
        }
        if ((fields & 128) && !voice->flag04) {
            properties->fields &= ~128;
        }
    }
}
