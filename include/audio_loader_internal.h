#ifndef ROBOTRON_AUDIO_LOADER_INTERNAL_H
#define ROBOTRON_AUDIO_LOADER_INTERNAL_H

#include "audio_bank_layout_internal.h"
#include "audio_control.h"
#include "audio_file_services_internal.h"
#include "audio_host_internal.h"

extern AudioFileCursor *D_8008D7B0;
extern int D_8008D7B4;
extern int D_8008D7B8;
extern int D_8008D7BC;
extern int D_8008D7C0;
extern unsigned char *D_8008D7C4;
extern unsigned char *D_8008D7C8;
extern unsigned int D_8008D7CC;
extern AudioErrorCallback D_8008D7D0;
extern void *D_8008D7D4;
extern unsigned int D_8008D848;
extern unsigned int D_8008D84C;
extern unsigned int D_8008D850;
extern unsigned int D_8008D854;
extern unsigned int D_8008D858;
extern unsigned int D_8008D85C;
extern int D_8008D860;
extern int D_8008D864;
extern AudioRecordTable D_80190280;
extern AudioPatchBank D_801902A8;
extern AudioContext D_801902C8;

void *func_8005892C(unsigned int size);
void func_8005894C(void);
int func_800588D4(unsigned char code, int first, int second, int third, int value);
int func_8005303C(unsigned char *source, unsigned char *allocation, unsigned int size);

#endif
