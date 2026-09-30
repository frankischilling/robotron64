#ifndef ROBOTRON_SDK_PI_WORD_H
#define ROBOTRON_SDK_PI_WORD_H

/* Confirmed prefix used by raw word and DMA services. */
typedef struct SdkPiWordHandle {
    unsigned char unknown00[5];
    unsigned char latency;
    unsigned char pageSize;
    unsigned char releaseDuration;
    unsigned char pulse;
    unsigned char domain;
    unsigned char unknown0A[2];
    unsigned int baseAddress;
} SdkPiWordHandle;

typedef char SdkPiWordHandlePrefixMustBe16Bytes[
    sizeof(SdkPiWordHandle) == 16 ? 1 : -1];

int func_8006E600(SdkPiWordHandle *handle, unsigned int address, unsigned int word);
int func_8006E650(SdkPiWordHandle *handle, unsigned int address, unsigned int *word);
int func_80067990(SdkPiWordHandle *handle, int direction, unsigned int address,
                  void *dramAddress, unsigned int size);

#endif
