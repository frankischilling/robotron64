#include "../../../include/actor_hulk_internal.h"

void func_8002C0AC(ActorBehaviorActorInternal *actor, int initialize)
{
    int x;
    ActorBehaviorActorInternal *target;
    unsigned int flags;

    if (initialize != 0) {
        actor->frame18 = ((func_8004CDE8() >> 3) % func_80039CD0(actor->objectIndex)) << 8;
        actor->angle08 = (func_8004CDE8() >> 3) % 4096;
        actor->field2C = actor->resource24->speed;
        actor->field6C = func_8003CC88(actor->angle08) * actor->resource24->speed / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * actor->resource24->speed / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
    }
    switch (actor->animation1F) {
    case 1:
    case 4:
    case 9:
        break;
    default:
        func_8001C0D0(D_80093988, actor->animation1F);
        break;
    case 3:
        actor->field2C = 0;
        actor->field6C = func_8003CC88(actor->angle08) * 0 / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * 0 / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        break;
    case 0:
        flags = actor->flags14;
        if (flags & 0x10) {
            if ((unsigned int)(D_8009EFA0 - actor->field48) > 150) {
                actor->flags14 = flags & ~0x10;
                actor->field2C = actor->resource24->speed;
                actor->field6C = func_8003CC88(actor->angle08) * actor->resource24->speed / 4096;
                actor->field70 = func_8003CC58(actor->angle08) * actor->resource24->speed / 4096;
                func_80039514(actor->objectIndex, actor->angle08);
            }
            break;
        }
        if (actor->parameter38 != 0) {
            func_8002A5DC(actor, D_800B009C);
            break;
        }
        if (initialize == 0 && !(flags & 2)) {
            if (D_8009EF94 == 0) {
                return;
            }
            if ((unsigned int)((func_8004CDE8() >> 3) %
                ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
                (unsigned int)D_8009EF94 != 0) {
                return;
            }
            flags = actor->flags14;
        }
        actor->flags14 = flags & ~2;
        func_8002A3E8(actor, D_800B009C, actor->resource24->speed);
        actor->field40 = (int)func_80027D8C((ActorMotionPositionInternal *)actor->position, 3, 0, 4, 0);
        if (actor->field40 != 0) {
            actor->angle08 = (func_8004CDE8() >> 3) % 4096;
        } else {
            actor->field40 = (int)D_8009B190[D_800AD168].actor08;
            if (actor->field40 != 0) {
                target = (ActorBehaviorActorInternal *)actor->field40;
                x = target->position[0] - actor->position[0];
                actor->angle08 = func_8003CD4C(target->position[1] - actor->position[1], x) & 0xFFF;
                if (D_800AD288 == 4 || D_800AD288 == 7) {
                    actor->angle08 ^= 0x800;
                }
            }
        }
        func_8002A5DC(actor, D_800B009C);
        break;

    }
}
