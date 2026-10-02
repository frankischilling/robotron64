#ifndef ROBOTRON_ACTOR_SPAWN_INTERNAL_H
#define ROBOTRON_ACTOR_SPAWN_INTERNAL_H

#include "actor_behavior_extra_internal.h"

typedef struct ActorSpawnResourceInternal {
    unsigned char unknown00[0x58];
    short period58;
} ActorSpawnResourceInternal;

typedef struct ActorSpawnSessionInternal {
    unsigned char unknown00[0x68];
    unsigned int timestamp68;
} ActorSpawnSessionInternal;

typedef char ActorSpawnResourceMustBe90Bytes[
    sizeof(ActorSpawnResourceInternal) == 0x5A ? 1 : -1];
typedef char ActorSpawnSessionMustBe108Bytes[
    sizeof(ActorSpawnSessionInternal) == 0x6C ? 1 : -1];

extern int D_800ACD90[11];
extern int D_800AC978;
extern int D_800B14AC;
extern TextGlyphResource D_8009F928;

ActorBehaviorActorInternal *func_8001A350(TextGlyphResource *resource, int *position);
void func_80029760(ActorBehaviorActorInternal *actor);
int func_8003614C(int sound, int value, int enabled, int extra);
void func_8002D3D4(ActorBehaviorActorInternal *actor, int initialize);

#endif
