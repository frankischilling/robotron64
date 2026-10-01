#ifndef ROBOTRON_AUDIO_PROPERTY_PIPELINE_INTERNAL_H
#define ROBOTRON_AUDIO_PROPERTY_PIPELINE_INTERNAL_H

#include "audio_properties_internal.h"

void func_80058050(AudioVoice *voice, int value);
void func_800580D4(AudioVoice *voice, int value);
void func_80058158(AudioVoice *voice, int value);
void func_800582A8(int handle, int slot, int value,
                   void (*callback)(AudioVoice *, int));

unsigned char *func_80059580(unsigned char *data, unsigned int *delay);
unsigned char *func_800595D4(unsigned char *data, unsigned int value);
unsigned char func_80059644(unsigned int value);

extern unsigned int D_80192750;
extern unsigned char D_80192754;

#endif
