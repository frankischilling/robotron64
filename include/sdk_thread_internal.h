#ifndef ROBOTRON_SDK_THREAD_INTERNAL_H
#define ROBOTRON_SDK_THREAD_INTERNAL_H

#include "scheduler.h"
#include "sdk_time.h"

/* The queue sentinel contains only the two fields used by queue traversal. */
typedef struct SdkThreadTail {
    OSThread *next;
    int priority;
} SdkThreadTail;

typedef char SdkThreadTailMustBe8Bytes[sizeof(SdkThreadTail) == 8 ? 1 : -1];

extern SdkThreadTail D_8008F1A0;
extern OSThread *D_8008F1A8;
extern OSThread *D_8008F1AC;
extern OSThread *D_8008F1B0;

void func_8006707C(OSThread **queue);
void func_8006717C(OSThread **queue, OSThread *thread);
OSThread *func_800671C4(OSThread **queue);
void func_800671D4(void);
void func_80067350(void);

#endif
