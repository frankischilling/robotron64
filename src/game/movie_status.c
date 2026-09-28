#include "../../include/movie.h"

extern int D_8009E578;

int func_80005354(void)
{
    int repeats;
    int finalFrame;

    if (D_800B14A8->field6C != 0) {
        if (D_8009E578 >= -1 && D_8009E578 < 2) {
            D_800B14A8->field68 = 2;
        }
    } else if (D_800B14A8->field08 == 2) {
        if (D_800B14A8->field28 >= (D_800B14A8->field30 << 8)) {
            D_800B14A8->field68 = 2;
        }
    } else if (D_800B14A8->field24 != 999) {
        repeats = D_800B14A8->field24 - 1 < 0 ? 0 : D_800B14A8->field24 - 1;
        finalFrame = D_800B14A8->field2C;
        if (D_800B14A8->field28 >=
            ((repeats * (finalFrame - D_800B14A8->field20 + 1) + finalFrame) << 8)) {
            D_800B14A8->field68 = 1;
        }
    }
    return D_800B14A8->field68;
}
