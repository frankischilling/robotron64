#ifndef ROBOTRON_AUDIO_FILE_SERVICES_INTERNAL_H
#define ROBOTRON_AUDIO_FILE_SERVICES_INTERNAL_H

typedef struct AudioFileCursor AudioFileCursor;
typedef void (*AudioLoadErrorCallback)(int argument, int error);

extern unsigned int D_80192BA4;
extern int D_80192BA8;
extern int D_80192BAC;
extern AudioLoadErrorCallback D_80192BB0;
extern int D_80192BB4;
extern AudioFileCursor *D_80192BB8;

AudioFileCursor *func_80058B0C(unsigned int address);
unsigned int func_80058B20(void *destination, unsigned int size, AudioFileCursor *cursor);
int func_80058B74(AudioFileCursor *cursor, unsigned int offset, int origin);
void func_80058BBC(AudioFileCursor *cursor);

void func_8005CCC0(int error);
void func_8005CCF8(AudioLoadErrorCallback callback, int argument);
int func_8005CD0C(void);
int func_8005CD1C(int index);
int func_8005CD48(void);
void func_8005CDB8(void);

#endif
