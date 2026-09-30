#ifndef ROBOTRON_SDK_VIDEO_MANAGER_H
#define ROBOTRON_SDK_VIDEO_MANAGER_H

#include "sdk_video_internal.h"
#include "sdk_device_manager.h"

typedef struct SdkVideoMessage {
    unsigned short type;
    unsigned char priority;
    unsigned char status;
    OSMesgQueue *returnQueue;
    unsigned int unknown08[4];
} SdkVideoMessage;

typedef char SdkVideoMessageMustBe24Bytes[sizeof(SdkVideoMessage) == 24 ? 1 : -1];

extern SdkDeviceManager D_8008F140;
extern OSThread D_801950B0;
extern unsigned char D_80195260[0x1000];
extern OSMesgQueue D_80196260;
extern OSMesg D_80196278[5];
extern SdkVideoMessage D_80196290;
extern SdkVideoMessage D_801962A8;
extern unsigned short D_801962C0;
extern SdkVideoContext D_8008F1D0[2];

void func_80068050(void);
void func_80064EC8(void *argument);
SdkVideoContext *func_8006AC80(void);
void func_8006AC90(void);

#endif
