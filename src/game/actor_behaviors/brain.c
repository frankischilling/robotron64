#include "../../../include/actor_brain_internal.h"

void func_8002CB48(ActorBehaviorActorInternal *actor, int initialize)
{
    int oscillation;
    int divisor;
    unsigned int elapsed;

    actor->countdown54 += D_8009EF94 * 10;
    oscillation = func_8003CC58(actor->countdown54);
    divisor = actor->resource24->actorKind == 11 ? 6 : 3;
    func_800399E4(actor->objectIndex, actor->resource24->scale *
        (oscillation / divisor + 4096) / 40960.0f);
    switch (actor->animation1F) {
    case 1:
    case 5:
        return;
    case 4:
        if ((unsigned int)(D_8009EFA0 - actor->field48) >= 3001) {
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        return;
    }
    if (actor->parameter38 != 0) {
        func_8002A414(actor, D_800B00AC);
    } else {
        if (!(actor->flags14 & 2)) {
            if (D_8009EF94 == 0) {
                goto check_time;
            }
            if ((unsigned int)((func_8004CDE8() >> 3) %
                ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
                (unsigned int)D_8009EF94 != 0) {
                goto check_time;
            }
        }
        func_8002A3E8(actor, D_800B00AC,
            ((func_8004CDE8() >> 3) %
             ((ActorBehaviorMoreResourceInternal *)actor->resource24)->range10) * 2 +
            actor->resource24->speed -
            ((ActorBehaviorMoreResourceInternal *)actor->resource24)->range10);
        if (!(actor->unknown00[3] < !actor->position[0] ||
            actor->unknown00[3] < !actor->position[1] ||
            !actor->position[0] < 60000 - actor->unknown00[3] ||
            !actor->position[1] < 60000 - actor->unknown00[3]) || (func_8004CDE8() >> 3) % (D_800B00A8 + 1) == 0) {
            actor->angle08 = (func_8004CDE8() >> 3) % 4096;
        } else {
            actor->angle08 = ((func_8004CDE8() >> 3) % 4096) & 0xFC00;
        }
        func_8002A414(actor, D_800B00AC);
    }
check_time:
    elapsed = D_8009EFA0 - actor->field48;
    if ((unsigned int)elapsed > D_800B00A0) {
        actor->field2C = 0;
        actor->field6C = func_8003CC88(actor->angle08) * 0 / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * 0 / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        func_80027AB8((GameActor *)actor, 5, 1);
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = func_80029B20,
            actor->timer0E = 4;
    }
}
