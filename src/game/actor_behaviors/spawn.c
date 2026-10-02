#include "../../../include/actor_spawn_internal.h"

void func_8002D3D4(ActorBehaviorActorInternal *actor, int initialize)
{
    unsigned int elapsed;
    unsigned int flags;
    int tickDelta;
    ActorBehaviorActorInternal *child;

    if (initialize != 0) {
        actor->angle08 = (func_8004CDE8() >> 3) % 4096;
        actor->field2C = actor->resource24->speed;
        actor->field6C = func_8003CC88(actor->angle08) * actor->resource24->speed / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * actor->resource24->speed / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
    }
    switch (actor->animation1F) {
    case 0:
        break;
    case 1:
        return;
    case 4:
        if ((unsigned int)(D_8009EFA0 - actor->field48) >= 3001) {
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        return;
    case 5:
        elapsed = D_8009EFA0 - actor->field48;
        if (elapsed < 200) {
            func_800399E4(actor->objectIndex,
                ((elapsed * 4096 / 200) * actor->resource24->scale) / 40960.0f);
        } else {
            func_800399E4(actor->objectIndex,
                (actor->resource24->scale << 12) / 40960.0f);
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        return;
    }
    if (actor->parameter38 != 0) {
        func_8002A5DC(actor, D_800B14AC);
        return;
    }
    flags = actor->flags14;
    if (flags & 2) {
        actor->angle08 += 0x800;
        actor->field2C = actor->resource24->speed;
        actor->field6C = func_8003CC88(actor->angle08) * actor->resource24->speed / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * actor->resource24->speed / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        return;
    }
    if (initialize == 0) {
        tickDelta = D_8009EF94;
        if (tickDelta == 0) {
            goto check_create;
        }
        if ((unsigned int)((func_8004CDE8() >> 3) %
            ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
            (unsigned int)(tickDelta = D_8009EF94) != 0) {
            goto check_create;
        }
        flags = actor->flags14;
    }
    actor->flags14 = flags & ~2;
    func_8002A3E8(actor, D_800B14AC, actor->resource24->speed);
    actor->angle08 = ((func_8004CDE8() >> 3) % 4) * 1024 + 512;
    func_8002A5DC(actor, D_800B14AC);
    return;

check_create:
    if ((unsigned int)(D_8009EFA0 - ((ActorSpawnSessionInternal *)&D_800AD138)->timestamp68) > 4000 && tickDelta != 0) {
        if ((unsigned int)((func_8004CDE8() >> 3) %
                ((ActorSpawnResourceInternal *)actor->resource24)->period58) /
                (unsigned int)(tickDelta = D_8009EF94) == 0) {
            if (D_800ACD90[5] + D_800ACD90[6] >= D_800AC978) {
                return;
            }
            func_80027AB8((GameActor *)actor, 2, 1);
            if (actor->flags14 & 0x40) {
                actor->flags14 &= ~0x40;
                actor->callback44(actor);
            }
            actor->flags14 |= 0x40, actor->callback44 = func_80029760,
                actor->timer0E = 9;
            return;
        }
    }
    if (actor->kind1C == 24 && tickDelta != 0 &&
        (unsigned int)((func_8004CDE8() >> 3) % 1000) /
            (unsigned int)D_8009EF94 == 0) {
        child = func_8001A350(&D_8009F928, actor->position);
        if (child != 0) {
            child->position[2] = 0;
        }
        func_8003614C(63, 0, 1, 0);
    }
}
