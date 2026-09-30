#include "../../include/actor_behavior_next_internal.h"

void func_8002A244(ActorBehaviorActorInternal *actor, int initialize)
{
    unsigned int elapsed;

    if (initialize != 0) {
        switch (((ActorBehaviorMoreResourceInternal *)actor->resource24)->behaviorKind02) {
        case 6:
            break;
        case 8:
        case 9:
            actor->countdown54 = 0;
            break;
        }
        return;
    }

    switch (((ActorBehaviorMoreResourceInternal *)actor->resource24)->behaviorKind02) {
    case 11:
        actor->position[2] = 0;
        func_800290B0(actor->objectIndex, actor->position);
        break;
    case 9:
        if (actor->animation1F != 1) {
            elapsed = D_8009EFA0 - actor->field48;
            if (elapsed >= 10001U) {
                func_80027AB8((GameActor *)actor, 1, 1);
                if (actor->flags14 & 0x40) {
                    actor->flags14 &= ~0x40;
                    actor->callback44(actor);
                }
                actor->flags14 |= 0x40, actor->callback44 = func_8001B324,
                    actor->timer0E = 999;
            }
        }
    case 8:
        func_80039514(actor->objectIndex, D_8009EFA0 << 2);
        break;
    case 13:
        if (actor->animation1F == 1) {
            elapsed = D_8009EFA0 - actor->field48;
            if (elapsed >= 600U) {
                actor->state21 = 2;
            } else {
                actor->field4C = (elapsed * 255) / 600U;
            }
        }
        break;
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 10:
    case 12:
        break;
    }
}
