#ifndef ROBOTRON_PLAYER_NAVIGATION_INTERNAL_H
#define ROBOTRON_PLAYER_NAVIGATION_INTERNAL_H

#include "actor_behavior_internal.h"
#include "save_game.h"

extern int D_800BA74C;
int func_8000DF14(int angle);
GameActor *func_800330F8(GamePlayerState *player,
                       ActorBehaviorActorInternal *actor,
                       int *x, int *y, int speed);

#endif
