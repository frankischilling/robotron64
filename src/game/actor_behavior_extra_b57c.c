#include "../../include/actor_behavior_extra_internal.h"

void func_8002B57C(ActorBehaviorActorInternal *actor, int initialize)
{
    ActorBehaviorActorInternal *playerActor;

    playerActor = D_8009B190[D_800AD168].actor08;

    if (initialize != 0) {
        actor->frame18 =
            ((func_8004CDE8() >> 3) % func_80039CD0(actor->objectIndex)) << 8;
        actor->angle08 =
            (func_8003CD4C(-actor->position[1], -actor->position[0]) + 0x100) & 0xE00;
        func_80039514(actor->objectIndex, actor->angle08);
    }

    if (actor->animation1F == 4) {
        if ((unsigned int)(D_8009EFA0 - actor->field48) >= 3001U) {
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        return;
    }

    if (actor->parameter38 != 0) {
        func_8002A5DC(actor, 200);
        return;
    }

    if (!(actor->flags14 & 2)) {
        if (D_8009EF94 == 0) {
            return;
        }
        if ((unsigned int)((func_8004CDE8() >> 3) %
                           ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
                (unsigned int)D_8009EF94 !=
            0) {
            return;
        }
    }

    func_8002A3E8(actor, 200,
                  ((ActorBehaviorMoreResourceInternal *)actor->resource24)->movement08);
    actor->angle08 =
        (func_8003CD4C(playerActor->position[1] - actor->position[1],
                       playerActor->position[0] - actor->position[0]) +
         0x100) &
        0xE00;
    actor->field48 = D_8009EFA0;
    func_8002A5DC(actor, 200);
}
