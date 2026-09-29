#include "../../include/sdk_pfs_internal.h"

static void func_8006984C(int channel, unsigned short address);

int func_80069630(OSMesgQueue *queue, int channel, unsigned short address,
                  unsigned char *buffer)
{
    int ret;
    int index;
    unsigned char *position;
    SdkContRamPacket response;
    int retry;

    ret = 0;
    position = (unsigned char *)&D_80194D20;
    retry = 2;
    func_80069A10();
    D_80194FE0 = 2;
    func_8006984C(channel, address);
    ret = func_80069A80(1, &D_80194D20);
    func_80062240(queue, 0, 1);
    do {
        ret = func_80069A80(0, &D_80194D20);
        func_80062240(queue, 0, 1);
        position = (unsigned char *)&D_80194D20;
        if (channel != 0) {
            for (index = 0; index < channel; index++) {
                position++;
            }
        }
        response = *(SdkContRamPacket *)position;
        ret = (response.receiveLength & 0xC0) >> 4;
        if (ret == 0) {
            unsigned char crc;
            crc = func_8006AAD0(response.data);
            if (crc != response.dataCrc) {
                ret = func_80069B30(queue, channel);
                if (ret != 0) {
                    func_80069A54();
                    return ret;
                }
                ret = SDK_PFS_ERR_CONTRFAIL;
            } else {
                for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++) {
                    *buffer++ = response.data[index];
                }
            }
        } else {
            ret = SDK_PFS_ERR_NOPACK;
        }
        if (ret != SDK_PFS_ERR_CONTRFAIL)
            break;
    } while (retry-- >= 0);
    func_80069A54();
    return ret;
}

static void func_8006984C(int channel, unsigned short address)
{
    unsigned char *position;
    SdkContRamPacket request;
    int index;

    position = (unsigned char *)D_80194D20.words;

    for (index = 0; index < 16; index++) {
        D_80194D20.words[index] = 0;
    }

    D_80194D20.packet.status = 1;
    request.dummy = 0xFF;
    request.transmitLength = 3;
    request.receiveLength = 33;
    request.command = 2;
    request.address = (address << 5) | func_8006AA20(address);
    request.dataCrc = 0xFF;
    for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++) {
        request.data[index] = 0xFF;
    }
    if (channel != 0) {
        for (index = 0; index < channel; index++) {
            *position++ = 0;
        }
    }
    *(SdkContRamPacket *)position = request;
    position += sizeof(SdkContRamPacket);
    position[0] = 0xFE;
}
