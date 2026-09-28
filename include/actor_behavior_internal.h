#ifndef ROBOTRON_ACTOR_BEHAVIOR_INTERNAL_H
#define ROBOTRON_ACTOR_BEHAVIOR_INTERNAL_H

#include "actor.h"
#include "object.h"
#include "object_recovery.h"
#include "scalar_math.h"

typedef struct ActorBehaviorActorInternal ActorBehaviorActorInternal;
typedef void (*ActorBehaviorCallbackInternal)(ActorBehaviorActorInternal *actor);

struct ActorBehaviorActorInternal {
    short unknown00[4];
    short angle08;
    short previousAngle0A;
    short objectIndex;
    short timer0E;
    short unknown10[2];
    unsigned int flags14;
    int frame18;
    unsigned char kind1C;
    unsigned char unknown1D[2];
    unsigned char animation1F;
    unsigned char mode20;
    unsigned char state21;
    unsigned char unknown22[2];
    TextGlyphResource *resource24;
    int field28;
    int field2C;
    int field30;
    int field34;
    int parameter38;
    int field3C;
    int field40;
    ActorBehaviorCallbackInternal callback44;
    int field48;
    int field4C;
    int field50;
    int countdown54;
    int field58;
    int field5C;
    int position[3];
    int field6C;
    int field70;
    int field74;
    ActorBehaviorActorInternal *next78;
};

typedef struct ActorBehaviorResourceInternal {
    unsigned char unknown00[8];
    int movement08;
} ActorBehaviorResourceInternal;

typedef char ActorBehaviorActorInternalMustBe124Bytes[
    sizeof(ActorBehaviorActorInternal) == 0x7C ? 1 : -1];

extern int D_8009EF94;

extern int func_80039CD0(int object);
extern void func_8001B324(ActorBehaviorActorInternal *actor);

void func_8002A3E8(ActorBehaviorActorInternal *actor, int parameter, int value);
void func_8002A414(ActorBehaviorActorInternal *actor, int duration);
void func_8002A5DC(ActorBehaviorActorInternal *actor, int duration);
void func_8002B31C(ActorBehaviorActorInternal *actor, int unused);
void func_8002B570(ActorBehaviorActorInternal *actor, int unused);
void func_8002B7A4(ActorBehaviorActorInternal *actor, int unused);
void func_8002B7B0(ActorBehaviorActorInternal *actor, int unused);
void func_8002BF88(ActorBehaviorActorInternal *actor);
void func_8002DC20(ActorBehaviorActorInternal *actor);
void func_8002DCB8(ActorBehaviorActorInternal *actor);
void func_8002DD40(ActorBehaviorActorInternal *actor, int enabled);

#endif
