#include "../../include/actor_position_pairs.h"

void func_800290B0(int object, int *position);

void func_80029020(void)
{
    int i;

    for (i = 0; i < 20; i++) {
        if (D_800A4580[i].follower) {
            D_800A4580[i].follower->position = D_800A4580[i].source->position;
            func_800290B0(D_800A4580[i].follower->objectIndex0C,
                         D_800A4580[i].follower->position.value);
        }
    }
}
