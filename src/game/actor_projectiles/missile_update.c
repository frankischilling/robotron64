#include "../../../include/early_game_state.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/actor_motion_internal.h"
#include "../../../include/save_game.h"

extern int D_8009EFA0;
extern int D_800AC974;

/* Complete callback research; no matching-source ownership is claimed. */
void func_80038830(EarlyGameActor *actor, int initialize)
{
    unsigned int kind;
    unsigned int elapsed;
    ActorResource5CInternal *resource;
    EarlyGameActor *selected;
    unsigned int progress;
    int speed;

    kind = actor->resource24->kind02;
    resource = &D_800AC998[kind];
    elapsed = (unsigned int)D_8009EFA0 - actor->field48;
    if (elapsed > (unsigned int)resource->value58) {
        actor->state21 = 2;
        return;
    }
    switch (kind) {
    case 9:
        if (initialize) {
            actor->callback00 = func_80005560;
        }
        break;
    case 4:
        if (initialize) {
            func_80039BE4(actor->objectIndex0C, 3);
            elapsed = (unsigned int)D_8009EFA0 - actor->field48;
        }
        func_80039BF0(actor->objectIndex0C, elapsed / 100 & 7);
        func_80039514(actor->objectIndex0C, 2048);
        if ((unsigned int)(resource->value58 * 99) / 100 <
            (unsigned int)D_8009EFA0 - actor->field48) {
            actor->field4C = 1;
        } else {
            actor->field4C = 0;
        }
        break;
    case 5:
        if (initialize) {
            actor->callback00 = func_80005560;
        } else if ((elapsed * 2 & 256) != 0) {
            actor->field4C = elapsed * 2 & 255;
        } else {
            actor->field4C = -elapsed * 2 & 255;
        }
        break;
    case 6:
        if (initialize) {
            actor->callback00 = func_80005560;
        }
        /* Fall through to the random movement and timer path. */
    case 10:
        if (initialize) {
            actor->field50 = D_8009EFA0;
            actor->field50 -= (func_8004CDE8() >> 3) % 250;
        }
        if (actor->field38 != 0) {
            func_8002A5DC((ActorBehaviorActorInternal *)actor, 250);
        } else if ((actor->flags14 & 2) != 0 ||
            (D_8009EF94 != 0 &&
             (unsigned int)((func_8004CDE8() >> 3) %
                ((ActorResource68Internal *)actor->resource24)->rate1A) /
                (unsigned int)D_8009EF94 == 0)) {
            selected = (EarlyGameActor *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08;
            speed = ((TextGlyphResource *)actor->resource24)->speed;
            if (D_800AD2F8.field08 == 0) {
                speed = speed * 5 / 10;
            }
            func_8002A3E8((ActorBehaviorActorInternal *)actor, 250, speed);
            actor->angle08 = func_8003CD4C(
                selected->position.value[1] - actor->position.value[1],
                selected->position.value[0] - actor->position.value[0]);
            func_8002A5DC((ActorBehaviorActorInternal *)actor, 250);
        }
        if ((unsigned int)D_8009EFA0 - actor->field50 > 250) {
            actor->field50 = D_8009EFA0;
            func_80015218(actor);
        }
        break;
    case 7:
        selected = (EarlyGameActor *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08;
        /* Fall through to the quantized heading path. */
    case 8:
        if (kind != 7) {
            selected = (EarlyGameActor *)func_80027D8C(
                (ActorMotionPositionInternal *)&actor->position, 3, 0, 4, 0);
            if (selected == 0) {
                selected = (EarlyGameActor *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08;
            }
        }
        progress = (D_800AC998[7].value58 / D_800AC974 *
            ((unsigned int)D_8009EFA0 - actor->field48)) /
            (unsigned int)resource->value58;
        if (actor->unknown23 < progress) {
            actor->unknown23 = progress;
            actor->angle08 = func_8003CD4C(
                selected->position.value[1] - actor->position.value[1],
                selected->position.value[0] - actor->position.value[0]) & 0xFF00;
            speed = ((TextGlyphResource *)actor->resource24)->speed;
            if (D_800AD2F8.field08 == 0) {
                speed = speed * 5 / 10;
            }
            actor->field2C = speed;
            actor->field6C = func_8003CC88(actor->angle08) * speed / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * speed / 4096;
            func_80039514(actor->objectIndex0C, actor->angle08);
        }
        break;
    }
}
