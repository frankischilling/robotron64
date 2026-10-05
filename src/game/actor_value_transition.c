#include "../../include/actor_animation_state.h"
#include "../../include/actor_damage_internal.h"

typedef struct ActorValueOwner {
    unsigned char unknown00[0xC];
    int value0C;
} ActorValueOwner;

int func_80035190(ActorBehaviorActorInternal *actor, int value, int unused)
{
    ActorValueOwner *owner;

    if (actor != 0) {
        owner = (ActorValueOwner *)actor->field3C;
        if (value < 257) {
            actor->state21 = 2;
            owner->value0C = 0;
            return 1;
        }
        func_80027AB8((GameActor *)actor, 6, 1);
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        (actor->flags14 |= 0x40,
         actor->callback44 = func_80029210,
         actor->timer0E = 999);
    }
    return 0;
}
