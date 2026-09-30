#include "../../include/actor_behavior_internal.h"

void func_8002DCB8(ActorBehaviorActorInternal *actor)
{
    func_80027AB8((GameActor *) actor, 6, 1);
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_8002DC20,
        actor->timer0E = 999;
}
