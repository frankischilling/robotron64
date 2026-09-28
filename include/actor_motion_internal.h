#ifndef ROBOTRON_ACTOR_MOTION_INTERNAL_H
#define ROBOTRON_ACTOR_MOTION_INTERNAL_H

#include "actor.h"
#include "object.h"
#include "object_recovery.h"
#include "scalar_math.h"

extern GameActor *D_800AA708;

extern int func_8004CDE8(void);

typedef struct ActorMotionPositionInternal {
    int x;
    int y;
    int z;
} ActorMotionPositionInternal;

int func_80027B9C(GameActor *actor, int mode, int angle, int unused);
void func_80027CE4(GameActor *first, int firstOffset, GameActor *second, int secondOffset);
GameActor *func_80027D8C(ActorMotionPositionInternal *position, int kind, int immediate,
                         int actorKindLimit, int animation);
int func_80027ED4(ActorMotionPositionInternal *position, int constrainAxes, int spacing);

#endif
