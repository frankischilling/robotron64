#include "../../include/early_input_internal.h"

void func_8001BF48(int *state)
{
    int index;

    state[6] = -1;
    for (index = 0; index < 14; index++) {
        D_8009E9E0.values[index] = -1;
        D_8009E9E0.timers[index] = 0;
    }
}
