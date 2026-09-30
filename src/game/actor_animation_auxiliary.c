#include "../../include/actor_animation_state.h"

void func_80029194(ActorBehaviorActorInternal *actor)
{
    actor->field48 = D_8009EFA0;
    func_8003B520(&actor->resource24->animation.tracks[8]->field08,
                 D_8009AFC0, 8);
    func_80027AB8((GameActor *)actor, 8, 0);
    func_8003945C(actor->objectIndex,
                 actor->resource24->animation.tracks[8]->loopIndex);
}
