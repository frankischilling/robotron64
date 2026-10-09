#ifndef ACTOR_COLLISION_CAPTURE_INTERNAL_H
#define ACTOR_COLLISION_CAPTURE_INTERNAL_H

#include "actor_behavior_internal.h"
#include "actor_behavior_more_internal.h"
#include "actor_motion_internal.h"

typedef void (*ActorContactSpawnInitializer)(GameActor *actor, int initialize);
/* View of element 33 in the already owned 88-byte primary resource pool. */
extern TextGlyphResource D_800B2740;
extern int func_8003945C(int object, int value);
extern int func_80039D4C(int object, int value);
extern void func_80036B00(int kind, ActorBehaviorActorInternal *actor, int *impulse);

int func_8001737C(ActorBehaviorActorInternal *first, ActorBehaviorActorInternal *second,
                  int *firstPosition, int *secondPosition);

#endif
