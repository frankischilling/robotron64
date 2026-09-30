#include "../../include/actor.h"

extern void func_80039E5C(int object, int value);

int func_800354A4(GameActor *actor)
{
    func_80039E5C(actor->objectIndex, 0);
    return 1;
}
