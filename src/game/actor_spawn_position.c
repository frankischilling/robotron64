#include "../../include/actor_motion_internal.h"

int func_80027ED4(ActorMotionPositionInternal *position, int constrainAxes, int spacing)
{
    GameActor *actor;
    int remaining = 100;
    int accepted;
    int minimumX;
    ActorMotionPositionInternal candidate;
    int minimumY;
    int multiplier;

    do {
        accepted = 1;
        minimumX = 3000;
        minimumY = 3000;
        candidate.x = ((func_8004CDE8() >> 3) % 3000) * 18 - 27000;
        candidate.y = ((func_8004CDE8() >> 3) % 3000) * 18 - 27000;
        candidate.z = 0;
        if (constrainAxes != 0) {
            if ((func_8004CDE8() >> 3) % 256 > 128) {
                if ((func_8004CDE8() >> 3) % 256 > 128) {
                    candidate.x = 0;
                } else {
                    candidate.x = 60000;
                }
            } else {
                if ((func_8004CDE8() >> 3) % 256 > 128) {
                    candidate.y = 0;
                } else {
                    candidate.y = 60000;
                }
            }
        }
        if (spacing == 0) {
            continue;
        }
        for (actor = D_800AA708; actor != 0; actor = actor->next) {
            if (actor->kind == 2) {
                multiplier = spacing * 30 / 10;
                minimumX *= multiplier;
                minimumY *= multiplier;
            }
            if (func_8004CEF0(candidate.x - actor->position[0]) < minimumX &&
                func_8004CEF0(candidate.y - actor->position[1]) < minimumY) {
                remaining--;
                accepted = 0;
                if (remaining <= 0) {
                    return 0;
                }
            }
            if (actor->kind == 2) {
                minimumX = 3000;
                minimumY = 3000;
            }
        }
    } while (!accepted);
    *position = candidate;
    return 1;
}
