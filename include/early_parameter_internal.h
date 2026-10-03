#ifndef ROBOTRON_EARLY_PARAMETER_INTERNAL_H
#define ROBOTRON_EARLY_PARAMETER_INTERNAL_H

#include "actor_dynamic_pool_internal.h"
#include "actor_setup_internal.h"
#include "early_game_state.h"
#include "early_game_more.h"
#include "save_game.h"
#include "scene_counter_internal.h"

extern int D_800AE304;
extern int D_8009EFA0;
extern int D_800972B0;
extern int D_800972C0;
extern short D_800972C8[8];
extern short D_80097318[8];
extern short D_80097328[8];
extern int D_800972D8[8];
extern ActorDynamicParameter *D_800972F8[8];

void func_8000E108(int index, ActorDynamicFirstGroup *group,
                  ActorDynamicParameter *parameter, int unused,
                  int offsetX, int offsetY);
void func_8000E328(void);
void func_8000E3B4(void);
int func_8000E4F0(int index);
void func_8000E894(EarlyGameActor *actor, int unused);
void func_8000EAF8(EarlyGameActor *actor, SceneBucketCounter *counter);

#endif
