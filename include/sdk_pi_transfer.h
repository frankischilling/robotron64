#ifndef ROBOTRON_SDK_PI_TRANSFER_H
#define ROBOTRON_SDK_PI_TRANSFER_H

typedef struct SdkPiBlockInfo {
    unsigned int errorStatus;
    void *dramAddress;
    void *correctionAddress;
    unsigned int sectorSize;
    unsigned int errorCount;
    unsigned int errorSectors[4];
} SdkPiBlockInfo;

typedef struct SdkPiTransferInfo {
    unsigned int commandType;
    unsigned short transferMode;
    unsigned short blockNumber;
    int sectorNumber;
    unsigned int deviceAddress;
    unsigned int bufferManagerShadow;
    unsigned int sequenceShadow;
    SdkPiBlockInfo blocks[2];
} SdkPiTransferInfo;

typedef char SdkPiBlockInfoMustBe36Bytes[sizeof(SdkPiBlockInfo) == 36 ? 1 : -1];
typedef char SdkPiTransferInfoMustBe96Bytes[sizeof(SdkPiTransferInfo) == 96 ? 1 : -1];

#endif
