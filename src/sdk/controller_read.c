#include "../../include/sdk_controller.h"

SdkPifRam D_80194FA0;

int func_80061FE0(OSMesgQueue *queue)
{
    int result = 0;
    int index;

    func_80069A10();
    if (D_80194FE0 != 1) {
        func_8006214C();
        result = func_80069A80(1, D_80194FA0.words);
        func_80062240(queue, 0, 1);
    }
    for (index = 0; index < 16; index++) {
        D_80194FA0.words[index] = 0xFF;
    }
    D_80194FA0.packet.status = 0;
    result = func_80069A80(0, D_80194FA0.words);
    D_80194FE0 = 1;
    func_80069A54();
    return result;
}

void func_800620A4(SdkControllerPad *pad)
{
    unsigned char *position;
    SdkControllerReadPacket response;
    int index;

    position = (unsigned char *)D_80194FA0.words;
    for (index = 0; index < D_80194FE1;
         index++, position += sizeof(SdkControllerReadPacket), pad++) {
        response = *(SdkControllerReadPacket *)position;
        pad->error = (response.receiveLength & 0xC0) >> 4;
        if (pad->error == 0) {
            pad->buttons = response.buttons;
            pad->stickX = response.stickX;
            pad->stickY = response.stickY;
        }
    }
}

void func_8006214C(void)
{
    unsigned char *position;
    SdkControllerReadPacket request;
    int index;

    position = (unsigned char *)D_80194FA0.words;
    for (index = 0; index < 16; index++) {
        D_80194FA0.words[index] = 0;
    }
    D_80194FA0.packet.status = 1;
    request.dummy = 255;
    request.transmitLength = 1;
    request.receiveLength = 4;
    request.command = 1;
    request.buttons = 65535;
    request.stickX = -1;
    request.stickY = -1;
    for (index = 0; index < D_80194FE1; index++) {
        *(SdkControllerReadPacket *)position = request;
        position += sizeof(SdkControllerReadPacket);
    }
    *position = 254;
}
