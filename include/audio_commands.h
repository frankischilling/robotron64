#ifndef ROBOTRON_AUDIO_COMMANDS_H
#define ROBOTRON_AUDIO_COMMANDS_H

#include "audio_control.h"
#include "audio_game.h"

extern AudioContext *D_801902EC;

int func_8005396C(AudioRecordSlot *slot, int index, int value,
                   int flags, int argument);
void func_80053C70(int index, int argument);
int func_80053CC0(int index);
void func_80053DAC(int index, int useArgument, int argument);
void func_80053EBC(int index);
void func_80053EE0(int index, int argument);
void func_80053F04(void);
void func_80053F38(void);
void func_80053F78(int index, int useArgument, int argument);
void func_80054178(int useArgument, int argument);
void func_80054268(void);
void func_8005428C(int argument);
void func_800542B0(void);
void func_800542D4(void);
void func_80054304(int useArgument, int argument);
unsigned char func_80054720(void);
unsigned char func_80054758(void);
void func_800547CC(void);
void func_800547FC(unsigned char value);
void func_80054A18(void);
void func_80054A48(unsigned char value);
unsigned char func_80054C24(void);
void func_80054C34(unsigned char value);
void func_80055760(int index, int value);
void func_800557A8(int index, int value, int argument);

void func_8005895C(void);
void func_8005899C(void);
void func_800592C0(unsigned char *destination, const unsigned char *source,
                   unsigned int count);
void func_800592F0(int command);
void func_80059348(const void *source, int count);
void func_800593F4(void *destination, int count);
void func_80059438(void);

#endif
