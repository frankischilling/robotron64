#include "../../../include/actor_behavior_internal.h"
#include "../../../include/actor_motion_internal.h"

extern int D_800BA784;
#define BOUNCE_ABS(value) ((value) < 0 ? (value) * -1 : (value))
#define BOUNCE_SIGN(value) ((value) < 0 ? -1 : ((value) > 0 ? 1 : 0))

int func_800186D8(ActorBehaviorActorInternal *actor)
{
    int x;
    int y;
    int angle;
    int changed = 0;
    int limit;
    int value;

    if (actor->position[1] <= (actor->unknown00[3] - 30000)) {
        actor->position[1] = (actor->unknown00[3] - 30000);
        actor->field6C = actor->field6C;
        actor->field70 = BOUNCE_ABS(actor->field70);
        if (actor->field6C || (BOUNCE_ABS(actor->field70))) {
            func_80039514(actor->objectIndex, func_8003CD4C(BOUNCE_ABS(actor->field70), actor->field6C));
        }
        func_800290B0(actor->objectIndex, actor->position);
        changed = 1;
    }
    if (actor->position[1] >= (30000 - actor->unknown00[3])) {
        y = actor->field70;
        actor->position[1] = (30000 - actor->unknown00[3]);
        actor->field6C = actor->field6C;
        actor->field70 = -(BOUNCE_ABS(y));
        changed = 1;
        if (actor->field6C || -BOUNCE_ABS(actor->field70)) {
            func_80039514(actor->objectIndex, func_8003CD4C(-(BOUNCE_ABS(actor->field70)), actor->field6C));
        }
        func_800290B0(actor->objectIndex, actor->position);
    }
    if (actor->position[0] <= (actor->unknown00[3] - 30000)) {
        x = actor->field6C;
        actor->position[0] = (actor->unknown00[3] - 30000);
        actor->field6C = BOUNCE_ABS(x);
        actor->field70 = actor->field70;
        changed = 1;
        if ((BOUNCE_ABS(actor->field6C)) || actor->field70) {
            func_80039514(actor->objectIndex, func_8003CD4C(actor->field70, BOUNCE_ABS(actor->field6C)));
        }
        func_800290B0(actor->objectIndex, actor->position);
    }
    if (actor->position[0] >= (30000 - actor->unknown00[3])) {
        x = actor->field6C;
        actor->position[0] = (30000 - actor->unknown00[3]);
        actor->field6C = (BOUNCE_ABS(x)) * (-1);
        actor->field70 = actor->field70;
        changed = 1;
        if (((BOUNCE_ABS(actor->field6C)) * (-1)) || actor->field70) {
            func_80039514(actor->objectIndex, func_8003CD4C(actor->field70, (BOUNCE_ABS(actor->field6C)) * (-1)));
        }
        value = actor->objectIndex;
        func_800290B0(value, actor->position);
    }
    if (D_800BA784) {
        limit = 42000 - actor->unknown00[3];
        if ((func_8004CEF0(actor->position[0]) + func_8004CEF0(actor->position[1])) > limit) {
            limit -= actor->unknown00[3];
            value = func_8004CEF0((actor->position[1] << 12) / actor->position[0]);
            changed = 1;
            actor->position[0] = BOUNCE_SIGN(actor->position[0]) * ((limit << 12) / (value + 4096));
            actor->position[1] = (limit - func_8004CEF0(actor->position[0])) * BOUNCE_SIGN(actor->position[1]);
            func_800290B0(actor->objectIndex, actor->position);
            angle = func_8003CD4C(actor->position[1] / 2, actor->position[0] / 2) & 4095;
            if (angle < 1024) {
                x = -actor->field70;
                y = -actor->field6C;
            }
            else if (angle < 2048) {
                x = -actor->field70;
                y = actor->field6C;
            }
            else if (angle < 3096) {
                x = -actor->field70;
                y = -actor->field6C;
            }
            else {
                x = actor->field70;
                y = -actor->field6C;
            }
            actor->field6C = x;
            actor->field70 = y;
            if (x || y) {
                func_80039514(actor->objectIndex, func_8003CD4C(y, x));
            }
        }
    }
    if (changed) {
        actor->angle08 = func_8003CD4C(actor->field70, actor->field6C);
    }
    return changed;
}
