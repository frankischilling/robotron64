#include "../../include/early_session_state.h"

void func_8000E6F0(GameActor *actor)
{
    D_800AD138.activeBehaviorActors[actor->resource->actorKind]--;
    actor->state = 2;
}
