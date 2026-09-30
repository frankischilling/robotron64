#ifndef ROBOTRON_SDK_DEVICE_MANAGER_H
#define ROBOTRON_SDK_DEVICE_MANAGER_H

#include "scheduler.h"
#include "sdk_pi_word.h"

typedef struct SdkDeviceManager {
    int active;
    OSThread *thread;
    OSMesgQueue *commandQueue;
    OSMesgQueue *eventQueue;
    OSMesgQueue *accessQueue;
    int (*dma)(int, unsigned int, void *, unsigned int);
    int (*extendedDma)(SdkPiWordHandle *, int, unsigned int, void *, unsigned int);
} SdkDeviceManager;

typedef char SdkDeviceManagerMustBe28Bytes[sizeof(SdkDeviceManager) == 28 ? 1 : -1];

int func_80067890(OSThread *thread);
void osSetThreadPri(OSThread *thread, int priority);

#endif
