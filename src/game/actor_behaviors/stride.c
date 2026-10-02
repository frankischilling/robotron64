#include "../../../include/actor_stride_internal.h"

void func_8002B7BC(ActorBehaviorActorInternal *actor, int initialize) {
    int duration;
    ActorBehaviorActorInternal *player;

    D_800BB130++;
    player = D_8009B190[D_800AD168].actor08;
    actor->flags14 |= 0x2000;
    duration = actor->resource24->speed * D_800B0094 / ((ActorBehaviorMoreResourceInternal *)actor->resource24)->distance18 + 1;
    if (initialize) {
        actor->angle08 = (func_8003CD4C(-actor->position[1], -actor->position[0]) + 0x100) & 0xE00;
        func_80039514(actor->objectIndex, actor->angle08);
        if (actor->resource24->actorKind != 1) {
            actor->field48 += (func_8004CDE8() >> 3) % 750;
        } else {
            func_80027AB8((GameActor *)actor, 8, 1);
            actor->frame18 = 0;
            actor->field4C = -20000 - (func_8004CDE8() >> 3) % 10000;
            actor->position[2] = -actor->field4C;
            func_800290B0(actor->objectIndex, actor->position);
            if (actor->flags14 & 0x40) { actor->flags14 &= ~0x40; actor->callback44(actor); }
            actor->flags14 |= 0x40, actor->callback44 = func_800292BC, actor->timer0E = 999;
        }
    }
    switch (actor->animation1F) {
    case 4:
        if ((unsigned)(D_8009EFA0 - actor->field48) >= 3000) func_80027AB8((GameActor *)actor, 0, 1);
        break;
    case 1:
        if (actor->position[2] < 0) actor->field74 -= -D_8009EF94 * 20;
        break;
    case 6:
        actor->position[2] = -(D_800B8F60 * actor->frame18 / 256) / func_80039CD0(actor->objectIndex);
        break;
    case 8:
        if (actor->resource24->actorKind == 2) {
            func_800399E4(actor->objectIndex, (float)(4096 - func_8003CC58(func_80039CD0(actor->objectIndex) * actor->frame18 * 2048 / 512) / 4 / 3 * actor->resource24->scale) / 40960.0f);
        } else {
            actor->position[2] = -(actor->field4C * (func_80039CD0(actor->objectIndex) - actor->frame18 / 256)) / func_80039CD0(actor->objectIndex);
        }
        break;
    case 7:
        actor->position[2] = -D_800B8F60;
        if ((unsigned)(D_8009EFA0 - actor->countdown54) > (unsigned)D_800B6FF0) {
            func_80027AB8((GameActor *)actor, 8, 1);
            if (actor->flags14 & 0x40) { actor->flags14 &= ~0x40; actor->callback44(actor); }
            actor->flags14 |= 0x40, actor->callback44 = func_800292BC, actor->timer0E = 999;
        } else if (actor->parameter38) {
            func_8002A5DC(actor, duration / 2);
        } else {

            func_8002A3E8(actor, duration / 2, actor->field34 = ((ActorBehaviorMoreResourceInternal *)actor->resource24)->distance18 * D_800B6FF4 / 100);
            actor->angle08 = func_8003CD4C(player->position[1] - actor->position[1], player->position[0] - actor->position[0]);
            func_8002A5DC(actor, duration / 2);
        }
        break;
    case 0:
        if (actor->parameter38) {
            func_8002A5DC(actor, duration);
        } else if ((actor->flags14 & 2) || (unsigned)(D_8009EFA0 - actor->field48) > (unsigned)((ActorBehaviorMoreResourceInternal *)actor->resource24)->period1A) {
            func_8002A3E8(actor, duration, actor->field34 = ((ActorBehaviorMoreResourceInternal *)actor->resource24)->distance18);
            actor->angle08 = (func_8003CD4C(player->position[1] - actor->position[1], player->position[0] - actor->position[0]) + 0x100) & 0xE00;
            if (actor->resource24->actorKind >= 2) actor->angle08 += (D_800BB130 - D_800BB134 / 2) * 50;
            actor->field48 = D_8009EFA0;
            func_8002A5DC(actor, duration);
        }
        if (actor->resource24->actorKind == 1 && actor->animation1F == 0 && D_8009EF94 && (unsigned)((func_8004CDE8() >> 3) % D_800B6FE8) / (unsigned)D_8009EF94 == 0 && (func_8004CDE8() >> 3) % 3 == 0) {
            func_80027AB8((GameActor *)actor, 6, 1);
            if (actor->flags14 & 0x40) { actor->flags14 &= ~0x40; actor->callback44(actor); }
            actor->flags14 |= 0x40, actor->callback44 = func_8002945C, actor->timer0E = 999;
            actor->field4C = D_800B8F60;
        }
        break;
    }
    if (actor->resource24->actorKind == 1) {
        func_80039BFC(actor->objectIndex, actor->position[2] != 0);
    }
}
