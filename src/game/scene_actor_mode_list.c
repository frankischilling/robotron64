#include "../../include/actor_animation_state.h"
#include "../../include/actor_motion_internal.h"

void func_80035CC8(int mode)
{
    ActorBehaviorActorInternal *actor;
    unsigned int flags;

    if (mode == 0) {
        actor = (ActorBehaviorActorInternal *)D_800AA708;
        while (actor != 0) {
            if (actor->kind1C == 2) {
                func_80027AB8((GameActor *)actor, 6, 1);
                actor->field2C = 0;
                func_8003CC88(0);
                actor->field6C = 0;
                func_8003CC58(0);
                actor->field70 = 0;
                func_80039514(actor->objectIndex, 0);
                func_80039E5C(actor->objectIndex, 1);
                flags = actor->flags14;
                if (flags & 0x40) {
                    actor->flags14 = flags & ~0x40;
                    actor->callback44(actor);
                    flags = actor->flags14;
                }
                actor->flags14 = flags | 0x40;
                actor->callback44 = func_80029194;
                actor->timer0E = 999;
            } else if (actor->kind1C == 6) {
                func_80039E5C(actor->objectIndex, 1);
            }
            actor = actor->next78;
        }
    } else {
        actor = (ActorBehaviorActorInternal *)D_800AA708;
        while (actor != 0) {
            if (actor->kind1C == 2 || actor->kind1C == 6) {
                func_80039E5C(actor->objectIndex, 0);
            }
            actor = actor->next78;
        }
    }
}
