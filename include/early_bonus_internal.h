#ifndef ROBOTRON_EARLY_BONUS_INTERNAL_H
#define ROBOTRON_EARLY_BONUS_INTERNAL_H

#include "actor_animation_state.h"
#include "early_session_state.h"

extern int D_80073570;
extern int D_80097340;
extern int D_80097344;
extern int D_80097348;
extern int D_8009734C;

GameActor *func_8000F030(ActorBehaviorActorInternal *actor, int index, int kind);
void func_8000F318(ActorBehaviorActorInternal *actor);
void func_8000FBC0(ActorBehaviorActorInternal *actor);
void func_8000F814(EarlyGameActor *actor);
void func_800107A0(void);

#endif
