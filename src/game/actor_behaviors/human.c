#include "../../../include/actor_human_internal.h"

void func_8002A808(ActorBehaviorActorInternal *actor, int initialize)
{
    int brightness;
    int randomAngle;
    int frameCount;
    int clockAngle;
    int difference;
    int color;

    if (initialize != 0) {
        actor->field2C = actor->resource24->speed;
        randomAngle = (func_8004CDE8() >> 3) % 4096;
        actor->field6C = func_8003CC88(randomAngle) * actor->resource24->speed / 4096;
        randomAngle = (func_8004CDE8() >> 3) % 4096;
        actor->field70 = func_8003CC58(randomAngle) * actor->resource24->speed / 4096;
        randomAngle = (func_8004CDE8() >> 3) % 4096;
        func_80039514(actor->objectIndex, randomAngle);
    }
    if (actor->resource24->actorKind < 4) {
        clockAngle = (D_8009EFA0 - actor->field48) * 2;
        brightness = func_8003CC58(clockAngle) / 80;
        color = brightness + 64;
        switch (actor->resource24->actorKind) {
        case 1:
            func_80039C1C(actor->objectIndex, color / 2, color / 6, color / 2);
            break;
        case 0:
            func_80039C1C(actor->objectIndex, color / 6, color / 6, color);
            break;
        case 2:
            func_80039C1C(actor->objectIndex, color, color / 6, color / 6);
            break;
        case 3:
            func_80039C1C(actor->objectIndex, color / 2, color / 2, color / 6);
            break;
        }
        switch (actor->animation1F) {
        default:
            func_8001C0D0(D_8009396C);
            return;
        case 1:
            if (func_800393FC(actor->objectIndex) == 110) {
                frameCount = func_80039CD0(actor->objectIndex);
                func_800397E0(actor->objectIndex,
                    ((4096 - (actor->frame18 << 4) / frameCount) * actor->resource24->scale) / 40960.0f);
                if (func_80039CD0(actor->objectIndex) * 200 < actor->frame18) {
                    func_80029D98(actor);
                }
                actor->position[2] = actor->frame18;
            }
            if ((unsigned int)(D_8009EFA0 - actor->field48) > D_800ACE28) {
                func_80029D98(actor);
            }
            return;
        case 0:
            if (actor->parameter38 != 0) {
                func_8002A5DC(actor, D_800ACE20);
                return;
            }
            if (!(actor->flags14 & 2) && initialize == 0) {
                if (D_8009EF94 == 0) {
                    return;
                }
                if ((unsigned int)((func_8004CDE8() >> 3) % ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) /
                    (unsigned int)D_8009EF94 != 0) {
                    return;
                }
            }
            func_8002A3E8(actor, D_800ACE20, actor->resource24->speed);
            actor->angle08 = (func_8004CDE8() >> 3) % 4096;
            actor->field48 = D_8009EFA0;
            func_8002A5DC(actor, D_800ACE20);
            return;
        case 3:
        case 9:
            return;

        }
    }
    if (actor->animation1F == 1) {
        actor->field74 = 0;
        actor->field70 = 0;
        actor->field6C = 0;
        return;
    }
    func_8004E820((EarlyGameActor *)actor);
    if (D_8009EF94 != 0 && (unsigned int)((func_8004CDE8() >> 3) %
        ((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) / (unsigned int)D_8009EF94 == 0) {
        goto choose_heading;
    }
    if (initialize == 0) {
        return;
    }
choose_heading:
    if (actor->angle08 == 0 || actor->angle08 == 2048) {
        difference = D_8009B190[D_800AD168].actor08->position[1] / 2 - actor->position[1] / 2;
        actor->angle08 = 2048 - (difference < 0 ? -1 : difference > 0 ? 1 : 0) * 1024;
    } else {
        difference = D_8009B190[D_800AD168].actor08->position[0] / 2 - actor->position[0] / 2;
        actor->angle08 = 1024 - (difference < 0 ? -1 : difference > 0 ? 1 : 0) * 1024;
    }
    actor->field2C = actor->resource24->speed;
    actor->field6C = func_8003CC88(actor->angle08) * actor->resource24->speed / 4096;
    actor->field70 = func_8003CC58(actor->angle08) * actor->resource24->speed / 4096;
    func_80039514(actor->objectIndex, actor->angle08);
}
