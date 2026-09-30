#include "../../include/actor_animation_state.h"

void func_80029C48(ActorBehaviorActorInternal *actor)
{
    func_80027AB8((GameActor *)actor, 0, 1);
    actor->field48 = D_8009EFA0;
    if (actor->value22 < 2) {
        if (actor->state21 == 0) {
            actor->state21 = 2;
            D_800AD138.activeBehaviorActors[actor->resource24->actorKind]--;
        }
    } else {
        actor->value22--;
        actor->field48 = D_8009EFA0;
        actor->field48 = actor->field48 - D_800B1BDC + 1200;
    }
}
