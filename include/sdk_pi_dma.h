#ifndef ROBOTRON_SDK_PI_DMA_H
#define ROBOTRON_SDK_PI_DMA_H

#include "sdk_device_manager.h"
#include "sdk_pi_device.h"

typedef struct SdkPiDmaMessage {
    unsigned short type;
    unsigned char priority;
    unsigned char status;
    OSMesgQueue *returnQueue;
    void *dramAddress;
    unsigned int cartridgeAddress;
    unsigned int size;
    SdkPiDeviceHandle *handle;
} SdkPiDmaMessage;

typedef char SdkPiDmaMessageMustBe24Bytes[sizeof(SdkPiDmaMessage) == 24 ? 1 : -1];

extern SdkDeviceManager D_8008E3D0;
OSMesgQueue *func_8006B570(void);
int func_8006B420(OSMesgQueue *queue, OSMesg message, int flags);
int func_80065840(SdkPiDmaMessage *message, int priority, int direction,
                  unsigned int cartridgeAddress, void *dramAddress,
                  unsigned int size, OSMesgQueue *returnQueue);

#endif
