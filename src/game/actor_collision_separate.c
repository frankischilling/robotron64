#include "../../include/actor_collision_services.h"
#include "../../include/actor_motion_internal.h"

void func_80018CC8(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second, int third, int fourth)
{
    int separation;
    int x;
    int y;

    separation = (first->unknown00[3] + second->unknown00[3]) * 6 / 4;
    x = first->position[0] - second->position[0];
    y = first->position[1] - second->position[1];
    if (x > 0 && x < separation) {
        x = separation - x;
        first->position[0] += x;
        func_800290B0(first->objectIndex, first->position);
    } else if (x < 0 && -x < separation) {
        x = separation + x;
        first->position[0] -= x;
        func_800290B0(first->objectIndex, first->position);
    }
    if (y > 0 && y < separation) {
        y = separation - y;
        first->position[1] += y;
        func_800290B0(first->objectIndex, first->position);
    } else if (y < 0 && -y < separation) {
        y = separation + y;
        first->position[1] -= y;
        func_800290B0(first->objectIndex, first->position);
    }
}
