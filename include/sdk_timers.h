#ifndef ROBOTRON_SDK_TIMERS_H
#define ROBOTRON_SDK_TIMERS_H

#include "scheduler.h"
#include "sdk_time.h"

typedef struct SdkTimer {
    struct SdkTimer *next;
    struct SdkTimer *previous;
    SdkTime interval;
    SdkTime value;
    OSMesgQueue *queue;
    OSMesg message;
} SdkTimer;

typedef char SdkTimerMustBe32Bytes[sizeof(SdkTimer) == 0x20 ? 1 : -1];

extern SdkTimer *D_8008F240;
extern unsigned int D_8019645C;
extern unsigned int D_80196460;

void func_800684D0(void);
void func_8006855C(void);
void func_800686D4(SdkTime cycles);
SdkTime func_80068748(SdkTimer *timer);
unsigned int func_8006ABA0(SdkTimer *timer, SdkTime countdown, SdkTime interval,
                          OSMesgQueue *queue, OSMesg message);
void func_8006E740(unsigned int compare);

#endif
