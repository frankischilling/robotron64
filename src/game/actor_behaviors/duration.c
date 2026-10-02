#include "../../../include/actor_duration_internal.h"

void func_8002AF2C(ActorBehaviorActorInternal *actor, int initialize)
{
    int duration;
    unsigned int elapsed;
    int phase;

    if (initialize != 0 &&
        ((ActorDurationResource *)actor->resource24)->behaviorKind02 == 1) {
        func_80039BE4(actor->objectIndex, 3);
    }
    duration = ((ActorDurationResource *)actor->resource24)->duration58;
    elapsed = D_8009EFA0 - actor->field48;
    if (elapsed >= (unsigned int)duration) {
        actor->state21 = 2;
        return;
    }
    switch (((ActorDurationResource *)actor->resource24)->behaviorKind02) {
    case 3:
        phase = elapsed * 5 / (unsigned int)duration;
        func_80039BF0(actor->objectIndex, (phase >= 5 ? 4 : phase) & 0xFF);
        break;
    case 2:
        actor->field2C =
            (((ActorDurationResource *)actor->resource24)->duration58 - (int)elapsed) *
            actor->countdown54 / ((ActorDurationResource *)actor->resource24)->duration58;
        actor->field6C = func_8003CC88(actor->angle08) *
            ((int)(((ActorDurationResource *)actor->resource24)->duration58 -
              (unsigned int)(D_8009EFA0 - actor->field48)) * actor->countdown54 /
             ((ActorDurationResource *)actor->resource24)->duration58) / 4096;
        actor->field70 = func_8003CC58(actor->angle08) *
            ((int)(((ActorDurationResource *)actor->resource24)->duration58 -
              (unsigned int)(D_8009EFA0 - actor->field48)) * actor->countdown54 /
             ((ActorDurationResource *)actor->resource24)->duration58) / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        elapsed = D_8009EFA0 - actor->field48;
        duration = ((ActorDurationResource *)actor->resource24)->duration58;
    case 1:
        actor->field4C = (elapsed << 8) / (unsigned int)duration;
        break;
    default:
        if (actor->field2C != actor->countdown54) {
            if (elapsed < 100) {
                actor->field2C = (int)elapsed * actor->countdown54 / 100;
                actor->field6C = func_8003CC88(actor->angle08) *
                    ((D_8009EFA0 - actor->field48) * actor->countdown54 / 100) / 4096;
                actor->field70 = func_8003CC58(actor->angle08) *
                    ((D_8009EFA0 - actor->field48) * actor->countdown54 / 100) / 4096;
                func_80039514(actor->objectIndex, actor->angle08);
            } else {
                actor->field2C = actor->countdown54;
                actor->field6C = func_8003CC88(actor->angle08) * actor->countdown54 / 4096;
                actor->field70 = func_8003CC58(actor->angle08) * actor->countdown54 / 4096;
                func_80039514(actor->objectIndex, actor->angle08);
            }
        }
        break;
    }
}
