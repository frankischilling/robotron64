#ifndef ROBOTRON_SDK_PI_DISK_H
#define ROBOTRON_SDK_PI_DISK_H

#include "sdk_pi_word.h"

/* Only the prefix and shadow word used by error recovery are confirmed here. */
typedef struct SdkPiTransferPrefix {
    unsigned char unknown00[16];
    unsigned int bufferManagerShadow;
} SdkPiTransferPrefix;

typedef struct SdkPiDiskHandlePrefix {
    SdkPiWordHandle prefix;
    unsigned int unknown10;
    SdkPiTransferPrefix transfer;
} SdkPiDiskHandlePrefix;

typedef char SdkPiTransferPrefixMustBe20Bytes[
    sizeof(SdkPiTransferPrefix) == 20 ? 1 : -1];
typedef char SdkPiDiskHandlePrefixMustBe40Bytes[
    sizeof(SdkPiDiskHandlePrefix) == 40 ? 1 : -1];

extern SdkPiDiskHandlePrefix *D_80196404;
void func_8006E2C4(void);

#endif
