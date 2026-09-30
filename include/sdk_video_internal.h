#ifndef ROBOTRON_SDK_VIDEO_INTERNAL_H
#define ROBOTRON_SDK_VIDEO_INTERNAL_H

#include "scheduler.h"
#include "sdk_time.h"

typedef struct SdkVideoScale {
    float factor;
    unsigned short offset;
    unsigned int scale;
} SdkVideoScale;

typedef struct SdkVideoContext {
    unsigned short state;
    unsigned short retraces;
    void *framebuffer;
    VideoMode *mode;
    unsigned int control;
    OSMesgQueue *queue;
    OSMesg message;
    SdkVideoScale horizontal;
    SdkVideoScale vertical;
} SdkVideoContext;

typedef char SdkVideoScaleMustBe12Bytes[sizeof(SdkVideoScale) == 12 ? 1 : -1];
typedef char SdkVideoContextMustBe48Bytes[sizeof(SdkVideoContext) == 48 ? 1 : -1];

extern SdkVideoContext *D_8008F230;
extern SdkVideoContext *D_8008F234;

void func_80065620(void *framebuffer);
void *func_80065670(void);
void *func_800656B0(void);
void func_8006AC90(void);

#endif
