#include "../../include/audio_sequence_internal.h"

void func_8005362C(AudioVoice *voice, AudioSequenceTrack *track, AudioProperties *properties)
{
    unsigned int fields;

    voice->flag80 = 1;
    voice->flag08 = 0;
    voice->flag04 = 0;
    voice->commandRedirect = 0;
    voice->pedalReleased = 1;
    voice->category = track->header->category;
    voice->backend = 1;
    voice->hardwareVoiceCount = 0;
    voice->property14 = track->header->property0A;
    voice->unknown20 = 0;
    voice->unknown24 = 0;
    voice->position28 = 0;
    voice->returnStack = voice->returnStackStart;
    voice->labelCount = track->header->labelCount;
    voice->commandBytes = track->header->commandBytes;
    voice->controlMask = track->header->controlMask;
    if (!(properties && properties->fields)) {
        fields = 0;
    } else {
        fields = properties->fields;
    }
    if (fields & 1) {
        voice->parameter0D = properties->parameter04;
    } else {
        voice->parameter0D = track->header->parameter06;
    }
    if (fields & 2) {
        voice->parameter0E = properties->parameter05;
    } else {
        voice->parameter0E = track->header->parameter07;
    }
    if (fields & 4) {
        voice->property04 = properties->parameter06;
    } else {
        voice->property04 = track->header->property02;
    }
    if (fields & 8) {
        voice->property06 = properties->parameter08;
    } else {
        voice->property06 = track->header->property04;
    }
    if (fields & 16) {
        if (voice->controlMask & (1 << properties->parameter0A)) {
            voice->flag40 = 1;
        } else {
            voice->flag40 = 0;
        }
    } else {
        voice->flag40 = 0;
    }
    if (fields & 32) {
        voice->property16 = properties->parameter0C;
    } else {
        voice->property16 = track->header->property0C;
    }
    voice->property1C = func_800589E4(func_800589DC(), voice->property14, voice->property16);
    if (fields & 64) {
        voice->position2C = voice->position28 + properties->offset10;
        voice->flag08 = 1;
    } else {
        voice->flag08 = 0;
    }
    if (fields & 128) {
        voice->flag04 = 1;
    } else {
        voice->flag04 = 0;
    }
    if (fields & 256) {
        voice->unknown0C = properties->unknown0B;
    } else {
        voice->unknown0C = track->header->parameter01;
    }
}
