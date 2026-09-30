#include "../../include/sdk_pi_device.h"
#include "../../include/sdk_pi_disk.h"

extern unsigned int D_8008E3C0;
void func_8006E3AC(void);

#define PI_READ(address) (*(volatile unsigned int *)(address))
#define PI_WRITE(address, value) (*(volatile unsigned int *)(address) = (value))
#define PI_WAIT(status) \
    status = PI_READ(0xA4600010); \
    while (status & 3) { status = PI_READ(0xA4600010); }

int func_8006DC20(void)
{
    unsigned int status;
    volatile unsigned int piStatus;
    unsigned int bufferStatus;
    SdkPiTransferInfo *transfer;
    SdkPiBlockInfo *block;

    status = 0;
    transfer = &((SdkPiDeviceHandle *)D_80196404)->transferInfo;
    block = &transfer->blocks[transfer->blockNumber];
    piStatus = PI_READ(0xA4600010);
    if (piStatus & 1) {
        D_8008E3C0 &= ~0x800;
        block->errorStatus = 29;
        func_8006E3AC();
        return 1;
    }
    PI_WAIT(piStatus);
    status = PI_READ(0xA5000508);
    if (status & 0x02000000) {
        PI_WAIT(piStatus);
        PI_WRITE(0xA5000510, transfer->bufferManagerShadow | 0x01000000);
        block->errorStatus = 0;
        return 0;
    }
    if (transfer->commandType == 2) {
        return 1;
    }
    if (status & 0x08000000) {
        PI_WAIT(piStatus);
        status = PI_READ(0xA5000508);
        block->errorStatus = 22;
        func_8006E3AC();
        PI_WRITE(0xA4600010, 2);
        D_8008E3C0 |= 0x100401;
        return 1;
    }
    if (transfer->commandType == 1) {
        if ((status & 0x40000000) == 0) {
            if (transfer->sectorNumber + 1 != transfer->transferMode * 85) {
                block->errorStatus = 24;
                func_8006E2C4();
                return 1;
            }
            PI_WRITE(0xA4600010, 2);
            D_8008E3C0 |= 0x100401;
            block->errorStatus = 0;
            func_8006E3AC();
            return 1;
        }
        block->dramAddress = (void *)((unsigned int)block->dramAddress + block->sectorSize);
        transfer->sectorNumber++;
        func_80067990((SdkPiWordHandle *)D_80196404, 1, 0x05000400,
                       block->dramAddress, block->sectorSize);
        return 1;
    }
    if (transfer->commandType == 0) {
        if (transfer->transferMode == 3) {
            if ((int)block->errorCount + 17 < transfer->sectorNumber) {
                block->errorStatus = 0;
                func_8006E2C4();
                return 1;
            }
            if ((status & 0x40000000) == 0) {
                block->errorStatus = 23;
                func_8006E2C4();
                return 1;
            }
        } else {
            block->dramAddress = (void *)((unsigned int)block->dramAddress + block->sectorSize);
        }
        bufferStatus = PI_READ(0xA5000510);
        if (((bufferStatus & 0x00200000) && (bufferStatus & 0x00400000)) ||
            (bufferStatus & 0x02000000)) {
            if (block->errorCount > 3) {
                if (transfer->transferMode != 3 || transfer->sectorNumber > 0x52) {
                    block->errorStatus = 23;
                    func_8006E2C4();
                    return 1;
                }
            } else {
                int errorNumber = block->errorCount;
                block->errorSectors[errorNumber] = transfer->sectorNumber + 1;
            }
            block->errorCount += 1;
        }
        if (status & 0x10000000) {
            if (transfer->sectorNumber != 87) {
                block->errorStatus = 24;
                func_8006E2C4();
            }
            if (transfer->transferMode == 2 && transfer->blockNumber == 0) {
                transfer->blockNumber = 1;
                transfer->sectorNumber = -1;
                transfer->blocks[1].dramAddress = (void *)((unsigned int)transfer->blocks[1].dramAddress - transfer->blocks[1].sectorSize);
                block->errorStatus = 22;
            } else {
                PI_WRITE(0xA4600010, 2);
                D_8008E3C0 |= 0x100401;
                transfer->commandType = 2;
                block->errorStatus = 0;
            }
            func_80067990((SdkPiWordHandle *)D_80196404, 0, 0x05000000,
                           block->correctionAddress, block->sectorSize * 4);
            return 1;
        }
        if (transfer->sectorNumber == -1 && transfer->transferMode == 2 &&
            transfer->blockNumber == 1) {
            SdkPiBlockInfo *firstBlock = &transfer->blocks[0];
            if (firstBlock->errorCount == 0) {
                if (((unsigned int *)firstBlock->correctionAddress)[0] |
                    ((unsigned int *)firstBlock->correctionAddress)[1] |
                    ((unsigned int *)firstBlock->correctionAddress)[2] |
                    ((unsigned int *)firstBlock->correctionAddress)[3]) {
                    firstBlock->errorStatus = 24;
                    func_8006E2C4();
                    return 1;
                }
            }
            firstBlock->errorStatus = 0;
            func_8006E3AC();
        }
        transfer->sectorNumber++;
        if (status & 0x40000000) {
            if (transfer->sectorNumber > 0x54) {
                block->errorStatus = 24;
                func_8006E2C4();
                return 1;
            }
            func_80067990((SdkPiWordHandle *)D_80196404, 0, 0x05000400,
                           block->dramAddress, block->sectorSize);
            block->errorStatus = 0;
            return 1;
        }
        if (transfer->sectorNumber <= 0x54) {
            block->errorStatus = 24;
            func_8006E2C4();
            return 1;
        }
        return 1;
    }
    block->errorStatus = 4;
    func_8006E2C4();
    return 1;
}
