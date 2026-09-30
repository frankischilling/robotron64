#ifndef ROBOTRON_SDK_EVENTS_H
#define ROBOTRON_SDK_EVENTS_H

#include "scheduler.h"

typedef struct SdkEventMessage {
    OSMesgQueue *queue;
    OSMesg message;
} SdkEventMessage;

typedef char SdkEventMessageMustBe8Bytes[sizeof(SdkEventMessage) == 8 ? 1 : -1];

extern SdkEventMessage D_80195030[];

#endif
