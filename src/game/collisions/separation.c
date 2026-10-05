#include "../../../include/actor_collision_separation_internal.h"
#include "../../../include/actor_motion_internal.h"

void func_80018E1C(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second,
                   int firstWeight, int secondWeight,
                   int *firstPosition, int *secondPosition)
{
    int angle;
    int distance;
    int radius;
    int total;

    total = secondWeight + firstWeight;
    if (total == 0) {
        total += 2;
        firstWeight++;
        secondWeight++;
    }
    radius = first->unknown00[3] + second->unknown00[3];
    distance = func_8003CCE8(
        (firstPosition[1] - secondPosition[1]) *
        (firstPosition[1] - secondPosition[1]) +
        (firstPosition[0] - secondPosition[0]) *
        (firstPosition[0] - secondPosition[0]));
    if (distance < radius) {
        first->flags14 |= 0x10000;
        second->flags14 |= 0x10000;
        angle = func_8003CD4C(firstPosition[1] - secondPosition[1],
                              firstPosition[0] - secondPosition[0]);
        distance = radius - distance;
        distance += 400;
        radius = total << 12;
        first->position[0] = firstPosition[0] +
            func_8003CC88(angle) * distance * firstWeight / radius;
        first->position[1] = firstPosition[1] +
            func_8003CC58(angle) * distance * firstWeight / radius;
        second->position[0] = secondPosition[0] -
            func_8003CC88(angle) * distance * secondWeight / radius;
        second->position[1] = secondPosition[1] -
            func_8003CC58(angle) * distance * secondWeight / radius;
        func_800290B0(first->objectIndex, first->position);
        func_800290B0(second->objectIndex, second->position);
    }
}
