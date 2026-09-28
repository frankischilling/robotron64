#ifndef ROBOTRON_AUDIO_HOST_INTERNAL_H
#define ROBOTRON_AUDIO_HOST_INTERNAL_H

#include "audio_properties_internal.h"

extern int D_8008D7E0;
extern int D_8008D7E4;
extern int D_8008D7E8;
extern int D_8008D7EC;
extern int D_8008D7F0;
extern void *D_8008D7F4;
extern unsigned int D_8008D7F8;
extern unsigned int D_8008D868;
extern unsigned int D_8008D86C;
extern int D_8008D870;
extern unsigned int D_8008D874;
extern void (*D_80190330)(void);
extern int (*D_80190334)(unsigned char, int, int, int, int);

void func_80058938(void *allocation);
void func_80059438(unsigned int *ticks, unsigned int *elapsed);
void func_8005A9AC(void);

#endif
