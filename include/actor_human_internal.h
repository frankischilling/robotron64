#ifndef ROBOTRON_ACTOR_HUMAN_INTERNAL_H
#define ROBOTRON_ACTOR_HUMAN_INTERNAL_H

#include "actor_behavior_extra_internal.h"
#include "actor_motion_internal.h"
#include "object_history_internal.h"

extern int D_800ACE20;
extern unsigned int D_800ACE28;
extern unsigned char D_8009396C[];

void func_8001C0D0(unsigned char *format, ...);
void func_80029D98(ActorBehaviorActorInternal *actor);
void func_8002A808(ActorBehaviorActorInternal *actor, int initialize);

#endif
