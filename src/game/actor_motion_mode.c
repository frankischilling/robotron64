#include "../../include/actor_motion_internal.h"

int func_80027B9C(GameActor *actor, int mode, int angle, int unused)
{
    actor->unknown20 = mode;
    angle = 0x400 - angle;

    switch (mode) {
    case 0:
        func_80039E5C(actor->objectIndex, 0);
        break;

    case 1:
        func_80039E5C(actor->objectIndex, 1);
        func_80039DCC(actor->objectIndex, 0x6B);
        break;

    case 2:
        func_800399E4(
            actor->objectIndex,
            (float)(0x1000 -
                    ((func_8003CC58(angle) / 4) * 4 * actor->resource->scale)) /
                40960.0f);
        func_80039E5C(actor->objectIndex, 1);
        break;

    default:
        func_80039E5C(actor->objectIndex, 1);
        func_800399E4(actor->objectIndex,
                      (float)(actor->resource->scale << 12) / 40960.0f);
        break;
    }

    return mode;
}
