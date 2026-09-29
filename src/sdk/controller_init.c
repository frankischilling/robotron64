#include "../../include/sdk_controller.h"

unsigned int D_8008F130 = 0;
unsigned char D_80194FE0;
unsigned char D_80194FE1;
SdkTimer D_80194FE8;
OSMesgQueue D_80195008;
OSMesg D_80195020[4];

extern SdkTime D_8008E3B0;

int func_80063D10(OSMesgQueue *queue, unsigned char *connected, SdkControllerStatus *status)
{
    OSMesg message;
    unsigned int result = 0;
    SdkTime currentTime;
    SdkTimer timer;
    OSMesgQueue timerQueue;

    if (D_8008F130) {
        return 0;
    }
    D_8008F130 = 1;
    currentTime = func_80061450();
    if (500000 * D_8008E3B0 / 1000000 > currentTime) {
        osCreateMesgQueue(&timerQueue, &message, 1);
        func_8006ABA0(&timer, 500000 * D_8008E3B0 / 1000000 - currentTime,
                      0, &timerQueue, &message);
        func_80062240(&timerQueue, &message, 1);
    }
    D_80194FE1 = 4;
    func_80063FD8(0);
    result = func_80069A80(1, D_80194FA0.words);
    func_80062240(queue, &message, 1);
    result = func_80069A80(0, D_80194FA0.words);
    func_80062240(queue, &message, 1);
    func_80063F08(connected, status);
    D_80194FE0 = 0;
    func_800699C0();
    osCreateMesgQueue(&D_80195008, D_80195020, 1);
    return result;
}

void func_80063F08(unsigned char *connected, SdkControllerStatus *status)
{
    unsigned char *position;
    SdkControllerStatusPacket response;
    int index;
    unsigned char found;

    found = 0;
    position = (unsigned char *)D_80194FA0.words;
    for (index = 0; index < D_80194FE1;
         index++, position += sizeof(SdkControllerStatusPacket), status++) {
        response = *(SdkControllerStatusPacket *)position;
        status->error = (response.receiveLength & 0xC0) >> 4;
        if (status->error == 0) {
            status->type = response.typeHigh << 8 | response.typeLow;
            status->status = response.status;
            found |= 1 << index;
        }
    }
    *connected = found;
}

void func_80063FD8(unsigned char command)
{
    unsigned char *position;
    SdkControllerStatusPacket request;
    int index;

    for (index = 0; index < 16; index++) {
        D_80194FA0.words[index] = 0;
    }
    D_80194FA0.packet.status = 1;
    position = (unsigned char *)D_80194FA0.words;
    request.dummy = 255;
    request.transmitLength = 1;
    request.receiveLength = 3;
    request.command = command;
    request.typeLow = 255;
    request.typeHigh = 255;
    request.status = 255;
    request.trailer = 255;
    for (index = 0; index < D_80194FE1; index++) {
        *(SdkControllerStatusPacket *)position = request;
        position += sizeof(SdkControllerStatusPacket);
    }
    *position = 254;
}
