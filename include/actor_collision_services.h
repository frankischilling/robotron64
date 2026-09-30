#ifndef ROBOTRON_ACTOR_COLLISION_SERVICES_H
#define ROBOTRON_ACTOR_COLLISION_SERVICES_H

#include "actor_behavior_internal.h"

unsigned char func_80017ACC(ActorBehaviorActorInternal *first,
                          ActorBehaviorActorInternal *second,
                          int *firstPosition, int *secondPosition);

void func_8001A410(ActorBehaviorActorInternal *first,
                    ActorBehaviorActorInternal *second);
int func_80016618(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second, int third, int fourth);

#endif
