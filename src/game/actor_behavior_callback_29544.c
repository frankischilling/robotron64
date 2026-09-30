#include "../../include/actor_behavior_more_internal.h"

void func_80029544(ActorBehaviorActorInternal *actor)
{
    func_80027AB8((GameActor *)actor, 7, 1);
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_800294A4,
        actor->timer0E = 999;
}
