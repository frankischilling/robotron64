#include "../../include/early_parameter_internal.h"

void func_8000EAF8(EarlyGameActor *actor, SceneBucketCounter *counter)
{
    int index = actor->field54;
    EarlyGameActor *child;
    int z;

    if (actor->field5C == (int)func_8000E894) {
        actor->field5C = (int)func_8000EAE4;
        D_80097328[index]++;
        if (D_80097328[index] >= D_80097318[index]) {
            z = actor->position.value[2];
            actor->position.value[2] = 0;
            child = (EarlyGameActor *)func_800283D4(9, &D_800B1BE8[D_800972B0 + 9], actor->position.value);
            D_800972B0++;
            if (D_800972B0 > 5) {
                D_800972B0 = 5;
            }
            actor->position.value[2] = z;
            func_80037144(D_800AD138.value4C, counter);
            if (child != 0) {
                child->resource24->callback54(child, 1);
            }
        }
    }
}
