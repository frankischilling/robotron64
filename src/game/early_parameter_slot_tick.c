#include "../../include/early_parameter_internal.h"

int func_8000E4F0(int index)
{
    ActorDynamicFirstGroup *group;
    ActorDynamicParameter *parameter;
    short *remaining;

    parameter = D_800972F8[index];
    D_800972D8[index] -= D_8009EF94;
    remaining = &D_800972C8[index];
    if (*remaining <= 0) {
        return 0;
    }
    group = &D_800AE4F4->firstGroups[parameter->value04];
    if (D_800972D8[index] <= 0) {
        func_8000E108(index, group, parameter, parameter->value10,
                      parameter->value14, parameter->value18);
        D_800972D8[index] = parameter->value20;
        D_800972C8[index]--;
    }
    return 1;
}
