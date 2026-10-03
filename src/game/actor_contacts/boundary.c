#include "../../../include/actor_behavior_internal.h"
#include "../../../include/actor_motion_internal.h"

extern int D_800BA784;

#define BOUNDARY_SIGN(value) ((value) < 0 ? -1 : ((value) > 0 ? 1 : 0))

int func_80018480(ActorBehaviorActorInternal *actor)
{
    int changed = 0;
    int limit;
    int ratio;
    int lower;
    int upper;

    lower = actor->unknown00[3] - 30000;
    if (actor->position[1] <= lower) {
        actor->position[1] = lower;
        func_800290B0(actor->objectIndex, actor->position);
        changed = 1;
    }
    upper = 30000 - actor->unknown00[3];
    if (actor->position[1] >= upper) {
        actor->position[1] = upper;
        func_800290B0(actor->objectIndex, actor->position);
        changed = 1;
    }
    lower = actor->unknown00[3] - 30000;
    if (actor->position[0] <= lower) {
        actor->position[0] = lower;
        func_800290B0(actor->objectIndex, actor->position);
        changed = 1;
    }
    upper = 30000 - actor->unknown00[3];
    if (actor->position[0] >= upper) {
        actor->position[0] = upper;
        func_800290B0(actor->objectIndex, actor->position);
        changed = 1;
    }
    if (D_800BA784 != 0) {
        limit = 42000 - actor->unknown00[3];
        if (func_8004CEF0(actor->position[0]) +
            func_8004CEF0(actor->position[1]) > limit) {
            int *position = actor->position;

            ratio = func_8004CEF0((actor->position[1] << 12) / actor->position[0]);
            changed = 1;
            actor->position[0] = BOUNDARY_SIGN(actor->position[0]) *
                ((limit << 12) / (ratio + 4096));
            ratio = func_8004CEF0(actor->position[0]);
            actor->position[1] = BOUNDARY_SIGN(actor->position[1]) *
                (limit - ratio);
            func_800290B0(actor->objectIndex, position);
        }
    }
    return changed;
}
