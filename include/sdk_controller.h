#ifndef ROBOTRON_SDK_CONTROLLER_H
#define ROBOTRON_SDK_CONTROLLER_H

#include "sdk_si.h"
#include "sdk_timers.h"

/* The final word is the PIF control word; clearing transfers include it. */
typedef union SdkPifRam {
    unsigned int words[16];
    struct {
        unsigned int payload[15];
        unsigned int status;
    } packet;
    unsigned long long alignment;
} SdkPifRam;

typedef struct SdkControllerReadPacket {
    unsigned char dummy;
    unsigned char transmitLength;
    unsigned char receiveLength;
    unsigned char command;
    unsigned short buttons;
    signed char stickX;
    signed char stickY;
} SdkControllerReadPacket;

typedef struct SdkControllerStatusPacket {
    unsigned char dummy;
    unsigned char transmitLength;
    unsigned char receiveLength;
    unsigned char command;
    unsigned char typeLow;
    unsigned char typeHigh;
    unsigned char status;
    unsigned char trailer;
} SdkControllerStatusPacket;

typedef struct SdkControllerPad {
    unsigned short buttons;
    signed char stickX;
    signed char stickY;
    unsigned char error;
} SdkControllerPad;

typedef struct SdkControllerStatus {
    unsigned short type;
    unsigned char status;
    unsigned char error;
} SdkControllerStatus;

typedef char SdkPifRamMustBe64Bytes[sizeof(SdkPifRam) == 64 ? 1 : -1];
typedef char SdkControllerReadPacketMustBe8Bytes[sizeof(SdkControllerReadPacket) == 8 ? 1 : -1];
typedef char SdkControllerStatusPacketMustBe8Bytes[sizeof(SdkControllerStatusPacket) == 8 ? 1 : -1];
typedef char SdkControllerPadMustBe6Bytes[sizeof(SdkControllerPad) == 6 ? 1 : -1];
typedef char SdkControllerStatusMustBe4Bytes[sizeof(SdkControllerStatus) == 4 ? 1 : -1];

extern SdkPifRam D_80194FA0;
extern unsigned char D_80194FE0;
extern unsigned char D_80194FE1;
extern SdkTimer D_80194FE8;
extern OSMesgQueue D_80195008;
extern OSMesg D_80195020[4];

int func_80061FE0(OSMesgQueue *queue);
void func_800620A4(SdkControllerPad *pad);
void func_8006214C(void);
int func_80063D10(OSMesgQueue *queue, unsigned char *connected, SdkControllerStatus *status);
void func_80063F08(unsigned char *connected, SdkControllerStatus *status);
void func_80063FD8(unsigned char command);

#endif
