#include "../../../include/actor_pursuit_internal.h"

void func_8002CF24(ActorBehaviorActorInternal *actor, int initialize)
{
    int halfFrames;
    EarlyGameActor *child;
    ActorBehaviorActorInternal *target;

    switch (actor->animation1F) {
    case 1:
        if (actor->resource24->actorKind == 26) {
            func_8001C49C(D_800939A4, actor->frame18 / 256);
        }
        return;
    case 8:
        halfFrames = func_80039CD0(actor->objectIndex) / 2;
        func_800399E4(actor->objectIndex,
            ((func_8003CC58(actor->frame18 * 12288 / (halfFrames << 8)) * (halfFrames - actor->frame18 / 256) / (halfFrames * 4) + 4096) *
             actor->resource24->scale) / 40960.0f);
        return;
    case 4:
        if ((unsigned int)(D_8009EFA0 - actor->field48) > 3000) {
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        return;
    case 3:
        if ((unsigned int)(D_8009EFA0 - actor->field48) > 1000) {
            actor->field40 = 0;
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        return;
    case 2:
        return;
    case 0:
    default:
        if (actor->resource24->actorKind == 28 &&
            (unsigned int)(D_8009EFA0 - actor->field48) > 100) {
            actor->field48 = D_8009EFA0;
            child = (EarlyGameActor *)func_800283D4(9, &D_800B27F0, actor->position);
            if (child != 0) {
                child->callback00 = func_80005560;
                func_80039C50(child->objectIndex0C, 4);
            }
        }
        if (initialize != 0 || actor->field40 == 0 ||
            (((ActorBehaviorActorInternal *)actor->field40)->kind1C != 3 &&
             ((ActorBehaviorActorInternal *)actor->field40)->kind1C != 2)) {
            actor->field40 = (int)func_80027D8C((ActorMotionPositionInternal *)actor->position, 3, 0, 4, 0);
            if (actor->field40 == 0) {
                actor->field40 = (int)D_8009B190[D_800AD168].actor08;
            }
        }
        if (actor->parameter38 != 0) {
            func_8002A5DC(actor, D_800B1BE4);
        } else if (actor->field40 != 0) {
            func_8002A3E8(actor, D_800B1BE4, actor->resource24->speed);
            target = (ActorBehaviorActorInternal *)actor->field40;
            actor->angle08 = func_8003CD4C(target->position[1] - actor->position[1], target->position[0] - actor->position[0]) & 0xFFF;
            func_8002A5DC(actor, D_800B1BE4);
        }
        if ((unsigned int)(D_8009EFA0 - ((ActorSpawnSessionInternal *)&D_800AD138)->timestamp68) > 4000 &&
            D_800ACD90[7] + D_800ACD90[8] < D_800AC97C) {
            if (D_8009EF94 == 0) {
                return;
            }
            if ((unsigned int)((func_8004CDE8() >> 3) %
                ((ActorSpawnResourceInternal *)actor->resource24)->period58) /
                (unsigned int)D_8009EF94 != 0) {
                return;
            }
            func_80027AB8((GameActor *)actor, 2, 1);
            actor->field2C = 0;
            actor->field6C = func_8003CC88(actor->angle08) * 0 / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * 0 / 4096;
            func_80039514(actor->objectIndex, actor->angle08);
            if (actor->flags14 & 0x40) {
                actor->flags14 &= ~0x40;
                actor->callback44(actor);
            }
            actor->flags14 |= 0x40, actor->callback44 = func_800295CC,
                actor->timer0E = 20;
        }
        break;
    }
}
