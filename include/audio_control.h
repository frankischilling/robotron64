#ifndef ROBOTRON_AUDIO_CONTROL_H
#define ROBOTRON_AUDIO_CONTROL_H

#include "audio_properties_internal.h"

typedef void (*AudioErrorCallback)(void *argument, int error);

void func_80052A00(int error);
void func_80052A38(unsigned char *destination, unsigned int count);
void func_80052A60(AudioErrorCallback callback, void *argument);
AudioContext *func_80052A74(void);
int func_80052A84(void);
int func_80052AA8(void);
int func_80052ACC(int index);
void func_80052B40(void);
void func_80052B64(void);
void func_80052B84(void);
int func_80052BA4(void);
void func_80052C08(int release);
void *func_80052C84(void);
void *func_80052C94(void);
void func_80052CA4(void);
void func_80052CF4(void);

#endif
