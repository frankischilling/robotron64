#ifndef ROBOTRON_ACTOR_DURATION_INTERNAL_H
#define ROBOTRON_ACTOR_DURATION_INTERNAL_H

#include "actor_behavior_extra_internal.h"

typedef struct ActorDurationResource {
    unsigned char unknown00[2];
    unsigned char behaviorKind02;
    unsigned char unknown03[0x55];
    int duration58;
} ActorDurationResource;

typedef char ActorDurationResourceMustBe92Bytes[
    sizeof(ActorDurationResource) == 0x5C ? 1 : -1];

void func_8002AF2C(ActorBehaviorActorInternal *actor, int initialize);

#endif
