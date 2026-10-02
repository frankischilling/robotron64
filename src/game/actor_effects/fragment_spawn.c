#include "../../../include/early_game_state.h"
#include "../../../include/actor_motion_internal.h"

void func_80036B00(int kind, ActorBehaviorActorInternal *actor, int *impulse)
{
    EarlyGameActor *fragment;
    int i;
    int count = 5;

    for (i = 0; i < count; i++) {
        fragment = (EarlyGameActor *)func_800283D4(
            9, &D_800B1BE8[kind], actor->position);
        if (fragment) {
            fragment->callback00 = func_80005560;
            func_80039C50(fragment->objectIndex0C, 4);
            fragment->field48 -= (func_8004CDE8() >> 3) % 1000;
            fragment->angle08 = (func_8004CDE8() >> 3) % 4096;
            fragment->field2C = (func_8004CDE8() >> 3) % 10 + 5;
            fragment->field6C = (func_8003CC88(fragment->angle08) * 5 +
                                (func_8004CDE8() >> 3) % 10) / 4096;
            fragment->field70 = (func_8003CC58(fragment->angle08) * 5 +
                                (func_8004CDE8() >> 3) % 10) / 4096;
            func_80039514(fragment->objectIndex0C, fragment->angle08);
            if (impulse) {
                fragment->field6C += impulse[0] / 20;
                fragment->field70 += impulse[1] / 20;
            }
            func_80039BE4(fragment->objectIndex0C, 3);
        }
    }
}
