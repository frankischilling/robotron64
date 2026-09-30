#include "../../include/actor_position_pairs.h"

ActorPositionPair D_800A4580[20];

int func_80027A10(EarlyGameActor *follower, EarlyGameActor *source)
{
    int i;

    for (i = 0; i < 20; i++) {
        if (D_800A4580[i].follower == 0) {
            D_800A4580[i].follower = follower;
            D_800A4580[i].source = source;
            return 1;
        }
    }
    return 0;
}
