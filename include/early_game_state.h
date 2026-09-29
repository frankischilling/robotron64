#ifndef ROBOTRON_EARLY_GAME_STATE_H
#define ROBOTRON_EARLY_GAME_STATE_H

#include "actor.h"

typedef struct EarlyGameActor EarlyGameActor;
typedef void (*EarlyGameActorCallback)(EarlyGameActor *actor);
typedef void (*EarlyGameResourceCallback)(EarlyGameActor *actor, int enabled);

typedef struct EarlyGamePosition {
    int x;
    int y;
    int z;
} EarlyGamePosition;

typedef struct EarlyGameActorResource {
    unsigned char unknown00[0x54];
    EarlyGameResourceCallback callback54;
} EarlyGameActorResource;

typedef struct EarlyGameActorOwner {
    unsigned char unknown00[0x10];
    EarlyGameActor *actor10;
} EarlyGameActorOwner;

struct EarlyGameActor {
    EarlyGameActorCallback callback00;
    int field04;
    short angle08;
    short field0A;
    short objectIndex0C;
    short timer0E;
    short value10[2];
    unsigned int flags14;
    int frame18;
    unsigned char kind1C;
    unsigned char unknown1D[2];
    unsigned char animation1F;
    unsigned char mode20;
    unsigned char state21;
    unsigned char unknown22[2];
    EarlyGameActorResource *resource24;
    int field28;
    int field2C;
    int field30;
    int field34;
    int field38;
    EarlyGameActorOwner *owner3C;
    int field40;
    EarlyGameActorCallback callback44;
    int field48;
    int field4C;
    int field50;
    int field54;
    int field58;
    int field5C;
    EarlyGamePosition position;
    int field6C;
    int field70;
    int field74;
    EarlyGameActor *next78;
};

typedef char EarlyGamePositionMustBe12Bytes[
    sizeof(EarlyGamePosition) == 0xC ? 1 : -1];
typedef char EarlyGameActorResourceMustBe88Bytes[
    sizeof(EarlyGameActorResource) == 0x58 ? 1 : -1];
typedef char EarlyGameActorMustBe124Bytes[
    sizeof(EarlyGameActor) == 0x7C ? 1 : -1];

float func_80012690(float target, float current, float maximumStep);
void func_8001276C(int advance, int unused);
void func_8001288C(int unused);
void func_80015184(int index, int *position);
void func_80015218(EarlyGameActor *source);
int func_800152AC(int first, int second, int third, int fourth);
void func_80015554(EarlyGameActor *actor);
int func_80015614(EarlyGameActor *first, EarlyGameActor *second,
                  int third, int fourth);

#endif
