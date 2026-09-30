#include "../../include/sdk_pfs.h"

SdkPifRam D_80194D60[4];
SdkPifRam D_80194E60[4];
unsigned char D_80194F60[32];
unsigned char D_80194F80[32];

int func_800636F0(SdkPfs *pfs)
{
    int index;
    int ret;
    unsigned char *position;
    SdkContRamPacket response;

    position = (unsigned char *)&D_80194D20;

    func_80069A10();

    D_80194FE0 = 3;
    func_80069A80(1, &D_80194D60[pfs->channel]);
    func_80062240(pfs->queue, 0, 1);
    ret = func_80069A80(0, &D_80194D20);
    func_80062240(pfs->queue, 0, 1);
    position = (unsigned char *)&D_80194D20;

    if (pfs->channel != 0)
        for (index = 0; index < pfs->channel; index++)
            position++;

    response = *(SdkContRamPacket *)position;
    ret = (response.receiveLength & 0xC0) >> 4;
    if (ret == 0 && response.dataCrc != 0) {
        ret = SDK_PFS_ERR_CONTRFAIL;
    }
    func_80069A54();
    return ret;
}

int func_80063858(SdkPfs *pfs)
{
    int index;
    int ret;
    unsigned char *position;
    SdkContRamPacket response;

    position = (unsigned char *)&D_80194D20;

    func_80069A10();

    D_80194FE0 = 3;
    func_80069A80(1, &D_80194E60[pfs->channel]);
    func_80062240(pfs->queue, 0, 1);
    ret = func_80069A80(0, &D_80194D20);
    func_80062240(pfs->queue, 0, 1);
    position = (unsigned char *)&D_80194D20;

    if (pfs->channel != 0)
        for (index = 0; index < pfs->channel; index++)
            position++;

    response = *(SdkContRamPacket *)position;
    ret = (response.receiveLength & 0xC0) >> 4;
    if (ret == 0 && response.dataCrc != 0xEB) {
        ret = SDK_PFS_ERR_CONTRFAIL;
    }
    func_80069A54();
    return ret;
}

void func_800639C4(int channel, unsigned short address, unsigned char *buffer,
                   SdkPifRam *motorData)
{
    unsigned char *position;
    SdkContRamPacket request;
    int index;

    position = (unsigned char *)motorData->words;
    for (index = 0; index < 15; index++)
        motorData->words[index] = 0;
    motorData->packet.status = 1;
    request.dummy = 0xFF;
    request.transmitLength = 35;
    request.receiveLength = 1;
    request.command = 3;
    request.address = (address << 5) | func_8006AA20(address);
    request.dataCrc = 0xFF;
    for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++)
        request.data[index] = *buffer++;
    if (channel != 0) {
        for (index = 0; index < channel; index++) {
            *position++ = 0;
        }
    }
    *(SdkContRamPacket *)position = request;
    position += sizeof(SdkContRamPacket);
    position[0] = 0xFE;
}

int func_80063B40(OSMesgQueue *queue, SdkPfs *pfs, int channel)
{
    int index;
    int ret;
    unsigned char temp[SDK_PFS_BLOCK_SIZE];
    pfs->queue = queue;
    pfs->channel = channel;
    pfs->status = 0;
    pfs->activeBank = 128;

    for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++)
        temp[index] = 128;

    ret = func_8006A6A0(queue, channel, 1024, temp, 0);
    if (ret == 2)
        ret = func_8006A6A0(queue, channel, 1024, temp, 0);
    if (ret != 0)
        return ret;

    ret = func_80069630(queue, channel, 1024, temp);
    if (ret == SDK_PFS_ERR_NEW_PACK)
        ret = SDK_PFS_ERR_CONTRFAIL;
    if (ret != 0)
        return ret;
    if (temp[31] != 128)
        return SDK_PFS_ERR_DEVICE;

    for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++) {
        D_80194F80[index] = 1;
        D_80194F60[index] = 0;
    }
    func_800639C4(channel, 1536, D_80194F80, &D_80194E60[channel]);
    func_800639C4(channel, 1536, D_80194F60, &D_80194D60[channel]);

    return 0;
}
