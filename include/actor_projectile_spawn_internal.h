#ifndef ACTOR_PROJECTILE_SPAWN_INTERNAL_H
#define ACTOR_PROJECTILE_SPAWN_INTERNAL_H

#include "actor_behavior_more_internal.h"
#include "early_game_state.h"
#include "actor_resource_5c_internal.h"

extern ActorResource5CInternal D_800AC998[11];
extern int D_800AC98C;
/* Views of elements 1, 2 and 3 of the already owned child-resource array. */
extern ActorResource5CInternal D_800AC9F4;
extern ActorResource5CInternal D_800ACA50;
extern ActorResource5CInternal D_800ACAAC;

EarlyGameActor *func_80038D8C(EarlyGamePosition *position, int kind,
                            ActorBehaviorPlayerInternal *owner, int angle);

#endif
