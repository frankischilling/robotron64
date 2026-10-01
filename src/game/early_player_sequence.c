#include "../../include/early_input_internal.h"

int func_8001BFB0(EarlyPlayerInputState *state)
{
    int index;
    int position;
    int buttons = state->held1C;

    D_8009764C = (buttons ^ D_80097648) & buttons;
    D_80097648 = buttons;
    for (index = 0; index < 14; index++) {
        if (D_8009E9E0.values[index] < 0) {
            D_8009E9E0.values[index] = 0;
        }
        position = D_8009E9E0.values[index];
        D_8009E9E0.timers[index] -= D_8009EF9C;
        if (D_8009E9E0.timers[index] <= 0) {
            D_8009E9E0.values[index] = 0;
        }
        if (D_8009764C != 0) {
            if (D_8009764C == D_8009EE08[index].buttons[position]) {
                D_8009E9E0.timers[index] = 1000;
                D_8009E9E0.values[index]++;
            } else {
                D_8009E9E0.timers[index] = 1000;
                D_8009E9E0.values[index] = 0;
            }
        } else if (D_8009E9E0.values[index] == D_8009EE08[index].length) {
            D_8009E9E0.values[index] = 0;
            D_8009E9E0.timers[index] = 0;
            state->sequence18 = index;
            return index;
        }
    }
    return -1;
}
