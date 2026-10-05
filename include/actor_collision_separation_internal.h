#ifndef ROBOTRON_ACTOR_COLLISION_SEPARATION_INTERNAL_H
#define ROBOTRON_ACTOR_COLLISION_SEPARATION_INTERNAL_H

#include "actor_behavior_internal.h"

void func_80018E1C(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second,
                   int firstWeight, int secondWeight,
                   int *firstPosition, int *secondPosition);

#endif
