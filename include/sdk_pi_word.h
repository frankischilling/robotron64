#ifndef ROBOTRON_SDK_PI_WORD_H
#define ROBOTRON_SDK_PI_WORD_H

/* The raw word services use this prefix of the peripheral handle. */
typedef struct SdkPiWordHandle {
    unsigned char unknown00[12];
    unsigned int baseAddress;
} SdkPiWordHandle;

typedef char SdkPiWordHandlePrefixMustBe16Bytes[
    sizeof(SdkPiWordHandle) == 16 ? 1 : -1];

int func_8006E600(SdkPiWordHandle *handle, unsigned int address, unsigned int word);
int func_8006E650(SdkPiWordHandle *handle, unsigned int address, unsigned int *word);

#endif
