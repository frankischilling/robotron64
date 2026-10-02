#ifndef ROBOTRON_ACTOR_BEHAVIOR_MORE_INTERNAL_H
#define ROBOTRON_ACTOR_BEHAVIOR_MORE_INTERNAL_H

#include "actor_behavior_internal.h"

typedef struct ActorBehaviorMoreResourceInternal {
    unsigned char unknown00[2];
    unsigned char behaviorKind02;
    unsigned char unknown03[5];
    int movement08;
    unsigned char unknown0C[4];
    short range10;
    unsigned char unknown12[6];
    short distance18;
    short period1A;
} ActorBehaviorMoreResourceInternal;

typedef struct ActorBehaviorPlayerInternal {
    unsigned char unknown00[8];
    ActorBehaviorActorInternal *actor08;
    unsigned char unknown0C[0xDA8];
} ActorBehaviorPlayerInternal;

typedef struct ActorBehaviorSessionInternal {
    unsigned char unknown00[0xE2];
    short countE2;
    short countE4;
    short countE6;
    short countE8;
} ActorBehaviorSessionInternal;

typedef char ActorBehaviorPlayerInternalMustBe3508Bytes[
    sizeof(ActorBehaviorPlayerInternal) == 0xDB4 ? 1 : -1];

extern ActorBehaviorPlayerInternal D_8009B190[2];
extern ActorBehaviorSessionInternal D_800AD138;
extern int D_800AD168;
extern int D_8009EFA0;
extern int D_800C8B7C;
extern int D_800B0098;
extern unsigned int D_800B1BDC;
extern int D_800B6FC8;
extern int D_800B6FD8;

extern int func_8004CDE8(void);
extern void func_8004EB60(ActorBehaviorActorInternal *actor);
extern ActorBehaviorActorInternal *func_8001AF44(int kind, int *position, ActorBehaviorActorInternal *actor);
extern void func_80027A10(ActorBehaviorActorInternal *actor, int value);
extern void func_800290B0(int object, int *position);
extern void func_800294A4(ActorBehaviorActorInternal *actor);
void func_80029154(ActorBehaviorActorInternal *actor);
void func_80029210(ActorBehaviorActorInternal *actor);
void func_800292BC(ActorBehaviorActorInternal *actor);
void func_8002937C(ActorBehaviorActorInternal *actor);
void func_8002945C(ActorBehaviorActorInternal *actor);
void func_80029544(ActorBehaviorActorInternal *actor);
void func_80029B20(ActorBehaviorActorInternal *actor);
extern void func_80029CF4(ActorBehaviorActorInternal *actor);
void func_80029D6C(ActorBehaviorActorInternal *actor);
void func_80029E5C(ActorBehaviorActorInternal *actor);

#endif
