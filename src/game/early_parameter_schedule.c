#include "../../include/early_parameter_internal.h"

void func_8000E3B4(void)
{
    int active = 0;
    int i;
    int index;
    ActorDynamicParameter *parameter;

    index = D_800AD138.parameterIndex54;
    if (index >= ((ActorDynamicPool *)D_800AE4F4)->parameterCount) {
        for (i = 0; i < 8; i++) {
            active |= func_8000E4F0(i);
        }
        if (active == 0) {
            D_800AE304 = 1;
        }
    } else {
        parameter = &((ActorDynamicPool *)D_800AE4F4)->parameters[index];
        if ((unsigned int)parameter->value00 < (unsigned int)(D_8009EFA0 - D_800AD138.parameterStart6C)) {
            D_800972F8[D_800972C0] = parameter;
            D_800972C8[D_800972C0] = parameter->value1C;
            D_80097318[D_800972C0] = parameter->value1C;
            D_80097328[D_800972C0] = 0;
            D_800972D8[D_800972C0] = 0;
            D_800AD138.parameterIndex54 = index + 1;
            D_800972C0++;
            D_800972C0 &= 7;
        }
        for (i = 0; i < 8; i++) {
            func_8000E4F0(i);
        }
    }
}
