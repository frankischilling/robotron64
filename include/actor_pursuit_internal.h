#ifndef ROBOTRON_ACTOR_PURSUIT_INTERNAL_H
#define ROBOTRON_ACTOR_PURSUIT_INTERNAL_H

#include "actor_spawn_internal.h"
#include "actor_motion_internal.h"
#include "early_game_state.h"

extern int D_800B1BE4;
extern int D_800AC97C;
extern TextGlyphResource D_800B27F0;
extern unsigned char D_800939A4[];

void func_8001C49C(unsigned char *format, ...);
void func_800295CC(ActorBehaviorActorInternal *actor);
void func_8002CF24(ActorBehaviorActorInternal *actor, int initialize);

#endif
