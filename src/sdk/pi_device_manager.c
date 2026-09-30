#include "../../include/sdk_pi_dma.h"

void func_8006E5A0(unsigned int mask);
void func_8006E6A0(unsigned int mask);
void func_8006E6F0(void);

void func_80067BC0(void *argument)
{
    SdkPiDmaMessage *message;
    OSMesg event;
    OSMesg dummy;
    int result;
    SdkDeviceManager *manager;
    int sendAgain;

    sendAgain = 0;
    message = 0;
    result = 0;
    manager = argument;
    while (1) {
        func_80062240(manager->commandQueue, (OSMesg *)&message, 1);
        if (message->handle != 0 && message->handle->type == 2 &&
            (message->handle->transferInfo.commandType == 0 ||
             message->handle->transferInfo.commandType == 1)) {
            SdkPiBlockInfo *block;
            SdkPiTransferInfo *transfer;

            transfer = &message->handle->transferInfo;
            block = &transfer->blocks[transfer->blockNumber];
            transfer->sectorNumber = -1;
            if (transfer->transferMode != 3) {
                block->dramAddress = (void *)((unsigned int)block->dramAddress - block->sectorSize);
            }
            if (transfer->transferMode == 2 && message->handle->transferInfo.commandType == 0) {
                sendAgain = 1;
            } else {
                sendAgain = 0;
            }
            func_80062240(manager->accessQueue, &dummy, 1);
            func_8006E5A0(0x100401);
            func_8006E600((SdkPiWordHandle *)message->handle, 0x05000510,
                          transfer->bufferManagerShadow | 0x80000000);
            while (1) {
                func_80062240(manager->eventQueue, &event, 1);
                transfer = &message->handle->transferInfo;
                block = &transfer->blocks[transfer->blockNumber];
                if (block->errorStatus == 29) {
                    unsigned int status;

                    func_8006E600((SdkPiWordHandle *)message->handle, 0x05000510,
                                  transfer->bufferManagerShadow | 0x10000000);
                    func_8006E600((SdkPiWordHandle *)message->handle, 0x05000510,
                                  transfer->bufferManagerShadow);
                    func_8006E650((SdkPiWordHandle *)message->handle, 0x05000508, &status);
                    if (status & 0x02000000) {
                        func_8006E600((SdkPiWordHandle *)message->handle, 0x05000510,
                                      transfer->bufferManagerShadow | 0x01000000);
                    }
                    block->errorStatus = 4;
                    *(volatile unsigned int *)0xA4600010 = 2;
                    func_8006E6A0(0x100C01);
                }
                func_800635A0(message->returnQueue, message, 0);
                if (sendAgain != 1) {
                    break;
                }
                if (message->handle->transferInfo.blocks[0].errorStatus != 0) {
                    break;
                }
                sendAgain = 0;
            }
            func_800635A0(manager->accessQueue, 0, 0);
            if (message->handle->transferInfo.blockNumber == 1) {
                func_8006E6F0();
            }
        } else {
            switch (message->type) {
            case 11:
                func_80062240(manager->accessQueue, &dummy, 1);
                result = manager->dma(0, message->cartridgeAddress, message->dramAddress, message->size);
                break;
            case 12:
                func_80062240(manager->accessQueue, &dummy, 1);
                result = manager->dma(1, message->cartridgeAddress, message->dramAddress, message->size);
                break;
            case 15:
                func_80062240(manager->accessQueue, &dummy, 1);
                result = manager->extendedDma((SdkPiWordHandle *)message->handle, 0,
                                               message->cartridgeAddress, message->dramAddress, message->size);
                break;
            case 16:
                func_80062240(manager->accessQueue, &dummy, 1);
                result = manager->extendedDma((SdkPiWordHandle *)message->handle, 1,
                                               message->cartridgeAddress, message->dramAddress, message->size);
                break;
            case 10:
                func_800635A0(message->returnQueue, message, 0);
                result = -1;
                break;
            default:
                result = -1;
                break;
            }
            if (result == 0) {
                func_80062240(manager->eventQueue, &event, 1);
                func_800635A0(message->returnQueue, message, 0);
                func_800635A0(manager->accessQueue, 0, 0);
            }
        }
    }
}
