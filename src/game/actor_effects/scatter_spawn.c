#include "../../../include/early_game_state.h"
#include "../../../include/actor_motion_internal.h"

extern TextGlyphResource D_800B5C30;

void func_800366C8(ActorBehaviorActorInternal *actor)
{
    int count = 3;
    EarlyGameActor *child;
    int i;

    for (i = 0; i < count; i++) {
        child = (EarlyGameActor *)func_800283D4(
            9, &D_800B5C30, actor->position);
        if (child != 0) {
            child->callback00 = func_80005560;
            child->field48 -= ((func_8004CDE8() >> 3) % 750) / 2;
            child->angle08 = (func_8004CDE8() >> 3) % 4096;
            child->field74 = -(-5 - (func_8004CDE8() >> 3) % 10);
            child->position.value[0] += (func_8004CDE8() >> 3) % 1000 - 500;
            child->position.value[1] += (func_8004CDE8() >> 3) % 1000 - 500;
            child->field2C = (func_8004CDE8() >> 3) % 20;
            child->field6C = func_8003CC88(child->angle08) *
                ((func_8004CDE8() >> 3) % 20) / 4096;
            child->field70 = func_8003CC58(child->angle08) *
                ((func_8004CDE8() >> 3) % 20) / 4096;
            func_80039514(child->objectIndex0C, child->angle08);
            func_80039BE4(child->objectIndex0C, 3);
            func_80039C50(child->objectIndex0C, 4);
        }
    }
}
