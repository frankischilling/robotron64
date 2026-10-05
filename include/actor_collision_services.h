#ifndef ROBOTRON_ACTOR_COLLISION_SERVICES_H
#define ROBOTRON_ACTOR_COLLISION_SERVICES_H

#include "actor_behavior_internal.h"
#include "early_game_state.h"

extern unsigned char D_80073950[36][3];

int func_80016950(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second,
                  int *firstPosition, int *secondPosition);

unsigned char func_80016C1C(ActorBehaviorActorInternal *first,
                           ActorBehaviorActorInternal *second,
                           int *firstPosition, int *secondPosition);

int func_80017A2C(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second, int third, int fourth);
int func_80017E50(EarlyGameActor *first, EarlyGameActor *second,
                  int *firstPosition, int *secondPosition);
unsigned char func_80017CDC(ActorBehaviorActorInternal *first,
                           ActorBehaviorActorInternal *second,
                           int *firstPosition, int *secondPosition);

unsigned char func_80017ACC(ActorBehaviorActorInternal *first,
                          ActorBehaviorActorInternal *second,
                          int *firstPosition, int *secondPosition);

void func_8001A410(ActorBehaviorActorInternal *first,
                    ActorBehaviorActorInternal *second);
void func_80018CC8(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second, int third, int fourth);
int func_80016618(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second, int third, int fourth);

#endif
