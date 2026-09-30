#include "../../include/actor_behavior_extra_internal.h"

void func_8002D918(ActorBehaviorActorInternal *actor, int initialize)
{
    if (initialize != 0) {
        actor->angle08 = (func_8004CDE8() >> 3) % 0x1000;
    }

    switch (actor->animation1F) {
    case 1:
        break;
    case 4:
        if ((unsigned int)(D_8009EFA0 - actor->field48) >= 3001U) {
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        break;
    case 5:
        break;
    default:
        if (actor->parameter38 != 0) {
            func_8002A414(actor, D_800B6FC8);
            break;
        }

        if (!(actor->flags14 & 2) && initialize == 0) {
            if (D_8009EF94 == 0) {
                goto fallback;
            }
            if ((unsigned int)((func_8004CDE8() >> 3) %
                               ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
                    (unsigned int)D_8009EF94 !=
                0) {
                goto fallback;
            }
        }

        func_8002A3E8(
            actor, D_800B6FC8,
            ((((func_8004CDE8() >> 3) %
               ((ActorBehaviorMoreResourceInternal *)actor->resource24)->range10) *
                  2 +
              ((ActorBehaviorMoreResourceInternal *)actor->resource24)->movement08 -
              ((ActorBehaviorMoreResourceInternal *)actor->resource24)->range10) /
             2));
        actor->angle08 = (((func_8004CDE8() >> 3) % 4) << 10) + 0x200;
        func_8002A414(actor, D_800B6FC8);
        break;

fallback:
        if (D_800B1BDC < (unsigned int)(D_8009EFA0 - actor->field48) &&
            D_800AD138.countE8 + D_800AD138.countE2 + D_800AD138.countE4 +
                    D_800AD138.countE6 <
                D_800B6FD8) {
            actor->field2C = 0;
            func_8003CC88(actor->angle08);
            actor->field6C = 0;
            func_8003CC58(actor->angle08);
            actor->field70 = 0;
            func_80039514(actor->objectIndex, actor->angle08);
            func_80027AB8((GameActor *)actor, 5, 1);
            if (actor->flags14 & 0x40) {
                actor->flags14 &= ~0x40;
                actor->callback44(actor);
            }
            actor->flags14 |= 0x40, actor->callback44 = func_80029CF4,
                actor->timer0E = 0;
            actor->field48 = D_8009EFA0;
        }
        break;
    }

    actor->position[2] = 3000;
}
