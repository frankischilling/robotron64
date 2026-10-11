#include "../../../include/player_navigation_internal.h"
#include "../../../include/actor_motion_internal.h"

GameActor *func_800330F8(GamePlayerState *player, ActorBehaviorActorInternal *actor,
                       int *x, int *y, int speed) {
    int direction;
    int angle1;
    int angle0;
    int angle3;
    int angle7;
    int dy;
    int delta;
    int avoidance;
    int scratchX;
    int angle5;
    GameActor *close0;
    GameActor *nearest0;
    GameActor *target3;
    GameActor *target7;
    GameActor *close1;
    GameActor *close5;
    GameActor *original0;
    ActorMotionPositionInternal *position;
    int dx;
    int cosine;

    position = (ActorMotionPositionInternal *) actor->position;
    direction = 0xDEADBEEF;
    close0 = func_80027D8C(position, 0, 0, 0x24, 0xDEAD);
    nearest0 = close0;
    original0 = close0;
    if (close0 != 0 &&
        (dx = actor->position[0], dy = actor->position[1],
         ((close0->position[1] - dy) / 32) * ((close0->position[1] - dy) / 32) +
         ((close0->position[0] - dx) / 32) * ((close0->position[0] - dx) / 32) < 0x21C9)) {
        dy = close0->position[1] - dy;
        dx = close0->position[0] - dx;
        angle0 = (func_8003CD4C(dy, dx) + 0x900) & 0xE00;
    } else {
        close0 = 0;
    }
    close5 = func_80027D8C(position, 5, 0, 0xB, 0xDEAD);
    if (close5 != 0 &&
        (dx = actor->position[0], dy = actor->position[1],
         ((close5->position[1] - dy) / 32) * ((close5->position[1] - dy) / 32) +
         ((close5->position[0] - dx) / 32) * ((close5->position[0] - dx) / 32) < 0x21C9)) {
        dy = close5->position[1] - dy;
        dx = close5->position[0] - dx;
        angle5 = (func_8003CD4C(dy, dx) + 0x900) & 0xE00;
    } else {
        close5 = 0;
    }
    close1 = func_80027D8C(position, 1, 0, 0x10, 0xDEAD);
    if (close1 != 0 &&
        (dx = actor->position[0], dy = actor->position[1],
         ((close1->position[1] - dy) / 32) * ((close1->position[1] - dy) / 32) +
         ((close1->position[0] - dx) / 32) * ((close1->position[0] - dx) / 32) < 0x21C9)) {
        dy = close1->position[1] - dy;
        dx = close1->position[0] - dx;
        angle1 = (func_8003CD4C(dy, dx) + 0x900) & 0xE00;
    } else {
        close1 = 0;
    }
    target7 = func_80027D8C(position, 7, 0, 0xB, 0xDEAD);
    if (target7 != 0 && player->saved.field6C == -1) {
        angle7 = (func_8003CD4C(target7->position[1] - actor->position[1],
                              target7->position[0] - actor->position[0]) + 0x100) & 0xE00;
    } else {
        target7 = 0;
    }
    target3 = func_80027D8C(position, 3, 0, 4, 0);
    if (target3 != 0) {
        angle3 = (func_8003CD4C(target3->position[1] - actor->position[1],
                              target3->position[0] - actor->position[0]) + 0x100) & 0xE00;
    } else {
        target3 = 0;
    }
    /* Retail retains the contradictory resource-kind branch below. */
    if (close0 != 0 || close1 != 0 || close5 != 0) {
        if (close0 != 0) {
            avoidance = angle0;
        } else if (close1 != 0) {
            avoidance = angle1;
        } else {
            avoidance = angle5;
        }
        if (target3 != 0) {
            if (target7 != 0) {
                scratchX = (target7->position[0] * 2 + target3->position[0] * 3) / 5;
                delta = (target7->position[1] * 2 + target3->position[1] * 3) / 5;
                direction = (func_8003CD4C(delta - actor->position[1],
                                           scratchX - actor->position[0]) + 0x100) & 0xE00;
            } else {
                direction = angle3;
            }
        } else if (target7 != 0) {
            direction = angle7;
        }
        if (direction != 0xDEADBEEF) {
            delta = func_8000DF14(direction - avoidance);
            if (delta > 0x300) {
                delta = 0x300;
            } else if (delta < -0x300) {
                delta = -0x300;
            }
            direction = avoidance + delta;
        } else {
            direction = avoidance;
        }
    } else if (target7 != 0) {
        direction = angle7;
    } else if (target3 != 0) {
        direction = angle3;
    } else if (close0 != 0 && close0->resource->actorKind < 5 &&
               close0->resource->actorKind >= 9 &&
               (scratchX = (close0->position[0] - actor->position[0]) / 32,
                delta = (close0->position[1] - actor->position[1]) / 32,
                scratchX * scratchX + delta * delta >= 0xD6592)) {
        direction = (angle0 + 0x800) & 0xFFF;
    } else if (original0 != 0 && D_800BA74C == -1) {
        scratchX = D_8009EFA4;
        dx = scratchX / 2;
        cosine = func_8003CC88(dx);
        dx = func_8003CC58(dx);
        direction = (func_8003CD4C(
            cosine * 240000 / 40960 - actor->position[1],
            dx * 240000 / 40960 - actor->position[0]) + 0x100) & 0xE00;
    } else {
        dx = actor->position[0];
        dy = actor->position[1];
        if ((dx / 32 * dx) / 32 + (dy / 32 * dy) / 32 >= 0x21CA) {
            direction = (func_8003CD4C(-dy, -dx) + 0x100) & 0xE00;
        }
    }
    if (direction != 0xDEADBEEF) {
        *x = func_8003CC88(direction) * speed / 4096;
        *y = func_8003CC58(direction) * speed / 4096;
    }
    return nearest0;
}
