#include "../../include/actor_animation_state.h"

void func_800294A4(ActorBehaviorActorInternal *actor)
{
    ActorBehaviorActorInternal *child;

    actor->field48 = D_8009EFA0;
    func_80027AB8((GameActor *)actor, 8, 1);
    child = func_8001A350(&D_8009F928, actor->position);
    if (child != 0) {
        child->position[2] = 0;
        child->field3C = (int)actor;
    }
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_80029210,
        actor->timer0E = 999;
}
