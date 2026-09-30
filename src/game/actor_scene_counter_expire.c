#include "../../include/actor_animation_state.h"

void func_80029D98(ActorBehaviorActorInternal *actor)
{
    if (actor->resource24->actorKind < 4) {
        D_800AD138.activeSceneActors[actor->resource24->actorKind]--;
        actor->state21 = 2;
    } else {
        func_80027AB8((GameActor *)actor, 1, 1);
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = func_80029D6C,
            actor->timer0E = 999;
    }
}
