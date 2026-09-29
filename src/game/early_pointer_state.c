#include "../../include/early_game_medium.h"

extern unsigned char D_800739D0[];
extern int func_8004C1C8(int value);

void func_8001A170(EarlyPointerState *state, int index, int value)
{
    int count;

    state->entry08 = D_800739D0 + index * 0x70;
    count = 0;
    do {
        if (func_8004C1C8(value) == 0) {
            value = 0;
        }
        count++;
    } while (count != 14);
    state->value04 = value;
}
