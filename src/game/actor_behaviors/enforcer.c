#include "../../../include/actor_enforcer_internal.h"

void func_8002C4AC(ActorBehaviorActorInternal *actor)
{
    int movement;
    int angle;
    ActorBehaviorActorInternal *child;
    ActorBehaviorActorInternal *target;
    int value;
    unsigned int elapsed;

    func_80039514(actor->objectIndex, D_8009EFA0 << 2);
    switch (actor->animation1F) {
    case 1:
    case 6:
    case 7:
        break;
    case 4:
        if ((unsigned int)(D_8009EFA0 - actor->field48) > 3000) {
            func_80027AB8((GameActor *)actor, 0, 1);
        }
        break;
    case 5:
        elapsed = D_8009EFA0 - actor->field48;
        if (elapsed > 1000) {
            func_800399E4(actor->objectIndex, (float)(actor->resource24->scale << 12) / 40960.0f);
            func_80027AB8((GameActor *)actor, 0, 1);
        } else {
            func_800399E4(actor->objectIndex,
                ((elapsed * 4096 / 1000) * actor->resource24->scale) / 40960.0f);
        }
        break;
    case 0:
    case 8:
    default:
        if (actor->parameter38 != 0) {
            func_8002A414(actor, D_800B00B4);
        } else if ((actor->flags14 & 2) || (D_8009EF94 != 0 &&
            (unsigned int)((func_8004CDE8() >> 3) %
                ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
                (unsigned int)D_8009EF94 == 0)) {
            target = D_8009B190[D_800AD168].actor08;
            value = func_8004CEF0(target->position[1] - actor->position[1]);
            movement = (((value + func_8004CEF0(target->position[0] - actor->position[0])) * 3 *
                ((ActorBehaviorMoreResourceInternal *)actor->resource24)->range10 / 60000 +
                actor->resource24->speed - ((ActorBehaviorMoreResourceInternal *)actor->resource24)->range10) * 2);
            if (movement < 0) {
                movement = 0;
            }
            func_8002A3E8(actor, D_800B00B4, movement);
            actor->angle08 = func_8003CD4C(target->position[1] - actor->position[1],
                                         target->position[0] - actor->position[0]) & 0xFFF;
            func_8002A414(actor, D_800B00B4);
        } else if (actor->resource24->actorKind == 14 && D_8009EF94 != 0 &&
            (unsigned int)((func_8004CDE8() >> 3) % 700) / (unsigned int)D_8009EF94 == 0) {
            func_80027AB8((GameActor *)actor, 6, 1);
            actor->field2C = 0;
            actor->field6C = func_8003CC88(0) * 0 / 4096;
            actor->field70 = func_8003CC58(0) * 0 / 4096;
            func_80039514(actor->objectIndex, 0);
            if (actor->flags14 & 0x40) {
                actor->flags14 &= ~0x40;
                actor->callback44(actor);
            }
            actor->flags14 |= 0x40, actor->callback44 = func_80029544,
                actor->timer0E = 999;
        } else if ((unsigned int)(D_8009EFA0 - ((ActorSpawnSessionInternal *)&D_800AD138)->timestamp68) > 4000 &&
            D_8009EF94 != 0 && (unsigned int)((func_8004CDE8() >> 3) %
                ((ActorSpawnResourceInternal *)actor->resource24)->period58) /
                (unsigned int)D_8009EF94 == 0) {
            child = (ActorBehaviorActorInternal *)func_800283D4(5, &D_800ACB08, actor->position);
            if (child != 0) {
                ((ActorSpawnDrawPrefixInternal *)child)->draw00 = func_8000CE34(actor->resource24->actorKind - 13);
                actor->position[2] = -1000;
                target = D_8009B190[D_800AD168].actor08;
                value = func_8003CD4C(target->position[1] - actor->position[1], target->position[0] - actor->position[0]);
                angle = (value + (func_8004CDE8() >> 3) % 1024 - 512) & 0xFFF;
                value = func_8004CEF0(target->position[0] - actor->position[0]);
                movement = ((value + func_8004CEF0(target->position[1] - actor->position[1])) / 3000 + 1) * child->resource24->speed / 60;
                if (D_800AD300 != 0) {
                    movement = movement * 11 / 9;
                }
                child->field2C = movement;
                child->field6C = func_8003CC88(angle) * movement / 4096;
                child->field70 = func_8003CC58(angle) * movement / 4096;
                func_80039514(child->objectIndex, angle);
                child->field3C = (int)actor;
                func_80039BE4(child->objectIndex, 3);
            }
        }
        break;
    }
    actor->position[2] = 2000;
}
