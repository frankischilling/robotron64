#include "../../include/actor_motion_internal.h"

void func_80027CE4(GameActor *first, int firstOffset, GameActor *second, int secondOffset)
{
    int xDifference;
    int yDifference;
    int angle;

    xDifference = second->position[0] - first->position[0];
    yDifference = second->position[1] - first->position[1];
    angle = func_8003CD4C(yDifference, xDifference);
    func_80039514(first->objectIndex, (angle + firstOffset) % 0x1000);
    func_80039514(second->objectIndex, (angle + secondOffset + 0x800) % 0x1000);
}
