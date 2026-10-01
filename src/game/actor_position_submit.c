#include "../../include/actor_motion_internal.h"

void func_800290B0(int object, int *position)
{
    ActorMotionPositionInternal copy;
    struct { float x, y, z; } output;

    copy = *(ActorMotionPositionInternal *)position;
    output.x = copy.x * 1400.0f / 60000.0f;
    output.y = copy.z * 1400.0f / 60000.0f;
    output.z = copy.y * 1400.0f / 60000.0f;
    func_80039614(object, &output.x);
}
