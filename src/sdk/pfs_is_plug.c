#include "../../include/sdk_pfs_internal.h"

SdkPifRam D_80194D20;

int func_80061A00(OSMesgQueue *queue, unsigned char *pattern)
{
    int ret;
    OSMesg message;
    unsigned char bitPattern;
    SdkControllerStatus status[4];
    int channel;
    unsigned char bits;
    int crcErrors;

    ret = 0;
    bits = 0;
    crcErrors = 3;
    func_80069A10();
    while (1) {
        func_80061BA0(0);
        ret = func_80069A80(1, &D_80194D20);
        func_80062240(queue, &message, 1);
        ret = func_80069A80(0, &D_80194D20);
        func_80062240(queue, &message, 1);
        func_80061C9C(&bitPattern, status);
        for (channel = 0; channel < D_80194FE1; channel++) {
            if ((status[channel].status & 4) == 0) {
                crcErrors--;
                break;
            }
        }
        if (D_80194FE1 == channel)
            crcErrors = 0;
        if (crcErrors < 1) {
            for (channel = 0; channel < D_80194FE1; channel++) {
                if (status[channel].error == 0 && (status[channel].status & 1) != 0)
                    bits |= 1 << channel;
            }
            func_80069A54();
            *pattern = bits;
            return ret;
        }
    }
}

void func_80061BA0(unsigned char command)
{
    unsigned char *position;
    SdkControllerStatusPacket request;
    int index;

    D_80194FE0 = command;
    for (index = 0; index < 16; index++) {
        D_80194D20.words[index] = 0;
    }
    D_80194D20.packet.status = 1;
    position = (unsigned char *)&D_80194D20;
    request.dummy = 0xFF;
    request.transmitLength = 1;
    request.receiveLength = 3;
    request.command = command;
    request.typeLow = 0xFF;
    request.typeHigh = 0xFF;
    request.status = 0xFF;
    request.trailer = 0xFF;
    for (index = 0; index < D_80194FE1; index++) {
        *(SdkControllerStatusPacket *)position = request;
        position += sizeof(SdkControllerStatusPacket);
    }
    *position = 0xFE;
}

void func_80061C9C(unsigned char *pattern, SdkControllerStatus *status)
{
    unsigned char *position;
    SdkControllerStatusPacket response;
    int index;
    unsigned char bits;

    bits = 0;
    position = (unsigned char *)&D_80194D20;
    for (index = 0; index < D_80194FE1;
         index++, position += sizeof(SdkControllerStatusPacket)) {
        response = *(SdkControllerStatusPacket *)position;
        status->error = (response.receiveLength & 0xC0) >> 4;
        if (status->error == 0) {
            status->type = response.typeHigh << 8 | response.typeLow;
            status->status = response.status;
            bits |= 1 << index;
        }
        status++;
    }
    *pattern = bits;
}
