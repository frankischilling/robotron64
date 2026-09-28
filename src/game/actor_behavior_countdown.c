#include "../../include/actor_behavior_internal.h"

void func_8002DC20(ActorBehaviorActorInternal *actor)
{
    actor->countdown54--;
    if (actor->countdown54 != 0) {
        return;
    }

    func_80027AB8((GameActor *) actor, 7, 1);
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_8001B324,
        actor->timer0E = 999;
}
