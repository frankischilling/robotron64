#ifndef ROBOTRON_SDK_PI_DEVICE_H
#define ROBOTRON_SDK_PI_DEVICE_H

#include "sdk_time.h"
#include "sdk_pi_transfer.h"

/* PI initialization clears this workspace; the device manager uses its fields. */
typedef struct SdkPiDeviceHandle {
    struct SdkPiDeviceHandle *next;
    unsigned char type;
    unsigned char latency;
    unsigned char pageSize;
    unsigned char releaseDuration;
    unsigned char pulse;
    unsigned char domain;
    unsigned char unknown0A[2];
    unsigned int baseAddress;
    unsigned int unknown10;
    SdkPiTransferInfo transferInfo;
} SdkPiDeviceHandle;

typedef char SdkPiDeviceHandleMustBe116Bytes[
    sizeof(SdkPiDeviceHandle) == 116 ? 1 : -1];

extern SdkPiDeviceHandle D_80196310;
extern SdkPiDeviceHandle D_80196390;
extern SdkPiDeviceHandle *D_8008E3EC;

int osPiRawReadIo(unsigned int address, unsigned int *word);
void func_800674C0(void *destination, unsigned int size);
SdkPiDeviceHandle *func_800675E0(void);
SdkPiDeviceHandle *func_800676D0(void);

#endif
