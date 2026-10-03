#include "../../../include/early_session_state.h"
#include "../../../include/actor_behavior_internal.h"

#define RATE (D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].movement24[D_800AD138.animationMovementAC].movement.rate04)
#define BASE_RATE (D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].movement24[0].movement.rate04)

void func_80010A3C(ActorBehaviorActorInternal *actor, int unused)
{
    switch (D_800AD138.animationMovementAC) {
    case 4:
        actor->field2C = RATE;
        if (RATE != 0) {
            actor->field6C = func_8003CC88((actor->angle08 - 1024) % 4096) * RATE / 4096;
            actor->field70 = func_8003CC58((actor->angle08 - 1024) % 4096) * RATE / 4096;
        }
        break;
    case 0:
        actor->field2C = RATE;
        actor->field6C = func_8003CC88(actor->angle08) * RATE / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * RATE / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        break;
    case 1:
        actor->field2C = RATE;
        actor->field6C = func_8003CC88(actor->angle08) * RATE / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * RATE / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        break;
    case 2:
    case 3:
        actor->angle08 += RATE * D_8009EF94;
        actor->field2C = 0;
        actor->angle08 %= 4096;
        actor->field6C = 0 * func_8003CC88(actor->angle08) / 4096;
        actor->field70 = 0 * func_8003CC58(actor->angle08) / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        break;
    case 5:
        break;
    default:
        actor->field2C = 0;
        actor->field6C = 0 * func_8003CC88(actor->angle08) / 4096;
        actor->field70 = 0 * func_8003CC58(actor->angle08) / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
    }
    switch (D_800AD138.animationCallbackB0) {
    case 4:
        actor->field2C = BASE_RATE;
        actor->field6C = func_8003CC88(actor->angle08) * BASE_RATE / 4096;
        actor->field70 = func_8003CC58(actor->angle08) * BASE_RATE / 4096;
        func_80039514(actor->objectIndex, actor->angle08);
        break;
    }
}
