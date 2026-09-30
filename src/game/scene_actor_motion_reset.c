#include "../../include/actor_behavior_internal.h"

extern int D_8009EFA0;

void func_80036DC8(ActorBehaviorActorInternal *actor, int unused)
{
    unsigned int elapsed;

    actor->position[2] =
        (func_8003CC58(((unsigned int)(D_8009EFA0 - actor->field48) << 11) / 2000U) *
         5000) /
        0x1000;

    elapsed = D_8009EFA0 - actor->field48;
    if (elapsed >= 2001U) {
        actor->frame18 = (elapsed << 8) / 2000U;
        func_80039BE4(actor->objectIndex, 0);
        actor->field2C = 0;
        func_8003CC88(0);
        actor->field6C = 0;
        func_8003CC58(0);
        actor->field70 = 0;
        func_80039514(actor->objectIndex, 0);
        func_800396F4(actor->objectIndex, 0xC00);
        actor->position[2] = 0;
        actor->field48 = D_8009EFA0;
        return;
    }

    actor->state21 = 2;
}
