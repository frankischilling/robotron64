#ifndef ROBOTRON_ACTOR_SPAWN_CALLBACK_INTERNAL_H
#define ROBOTRON_ACTOR_SPAWN_CALLBACK_INTERNAL_H

#include "actor_behavior_extra_internal.h"

typedef struct ActorSpawnChildResourceInternal {
    unsigned char unknown00[0x5C];
} ActorSpawnChildResourceInternal;

typedef struct ActorSpawnDrawPrefixInternal {
    int (*draw00)(void *state);
} ActorSpawnDrawPrefixInternal;

typedef char ActorSpawnChildResourceMustBe92Bytes[
    sizeof(ActorSpawnChildResourceInternal) == 0x5C ? 1 : -1];
typedef char ActorSpawnDrawPrefixMustBe4Bytes[
    sizeof(ActorSpawnDrawPrefixInternal) == 4 ? 1 : -1];

extern int D_800ACD90[11];
extern ActorSpawnChildResourceInternal D_800AC998[];
extern int D_800AC978;
extern int D_800AD300;

int func_8000C2F4(void *state);
int func_8003614C(int sound, int value, int enabled, int extra);
void func_80036ED0(int value);
void func_80029760(ActorBehaviorActorInternal *actor);

#endif
