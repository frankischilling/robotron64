#include "../../include/actor_behavior_extra_internal.h"

void func_8002B32C(ActorBehaviorActorInternal *actor, int initialize)
{
    ActorBehaviorActorInternal *playerActor;

    playerActor = D_8009B190[D_800AD168].actor08;

    switch (actor->animation1F) {
    case 7:
        if (actor->position[2] > 0) {
            actor->field74 = 0;
        } else {
            actor->field74 += 10;
        }
        return;
    case 3:
    case 6:
        func_80027A10(actor, actor->field3C);
        return;
    }

    if ((unsigned int)(D_8009EFA0 - actor->field48) >= 10001U) {
        actor->field48 = D_8009EFA0;
        func_80027AB8((GameActor *)actor, 1, 1);
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = func_8001B324,
            actor->timer0E = 999;
        return;
    }

    if (actor->parameter38 != 0) {
        func_8002A5DC(actor, D_800B0098);
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

    func_8002A3E8(actor, D_800B0098,
                  ((ActorBehaviorMoreResourceInternal *)actor->resource24)->movement08);
    actor->angle08 =
        (func_8003CD4C(playerActor->position[1] - actor->position[1],
                       playerActor->position[0] - actor->position[0]) +
         0x80) &
        0xF00;
    func_8002A5DC(actor, D_800B0098);
}
