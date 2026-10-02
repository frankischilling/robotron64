#include "../../include/actor_behavior_internal.h"
#include "../../include/controller_input.h"
#include "../../include/debug_output.h"
#include "../../include/early_input_internal.h"
#include "../../include/sound_bridge_internal.h"

extern int D_800BEF68;
extern unsigned char D_80094244[];

void func_80035E3C(ActorBehaviorActorInternal *actor, int speed,
                   EarlyPlayerInputState *input)
{
    int x;
    int y;
    int movementSpeed;
    int forward;
    int stickX;
    int stickY;

    if (D_8007394C) {
        movementSpeed = speed;
        speed = func_8003C180();
        if (speed == 0) {
            stickX = D_8013DBB8[0];
            func_8003CF88(D_80094244, stickX, stickY = D_8013DBC8[0]);
            if (func_8004CEF0(stickX) < 5) {
                stickX = 0;
            }
            if (func_8004CEF0(stickY) < 5) {
                stickY = 0;
            }
            actor->angle08 += stickX * 10 / 200;
            forward = stickY * 10 / 400;
            if (input->held1C & 1) {
                actor->angle08 -= 55;
            }
            if (input->held1C & 2) {
                actor->angle08 += 55;
            }
            if (input->held1C & 4) {
                forward += movementSpeed;
            }
            if (input->held1C & 8) {
                forward -= movementSpeed;
            }
        } else {
            forward = 0;
        }
        x = func_8003CC88(actor->angle08) * forward / 4096;
        y = func_8003CC58(actor->angle08) * forward / 4096;
        actor->field6C = x;
        actor->field70 = y;
        if (x || y) {
            func_80039514(actor->objectIndex, func_8003CD4C(y, x));
        }
        if (func_8003C180() == 1) {
            D_800BEF68 = (D_8013DBB8[0] << 4) + actor->angle08;
        } else {
            D_800BEF68 = actor->angle08;
        }
    }
}
