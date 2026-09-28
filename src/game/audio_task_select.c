#include "../../include/audio_runtime.h"

extern int D_8008D798;
extern int D_8008D79C;
extern int D_8008D7A4;
RspTask *func_8005211C(void)
{
    RspTask *task;

    if (D_8008D7A4 == 0) {
        return 0;
    }

    task = func_800521C8(D_80190188[D_8008D79C]);
    D_8008D7A0 = D_80190188[D_8008D79C];
    if (++D_8008D79C == 3) {
        D_8008D79C = 0;
    }
    if (task != 0) {
        D_8008D798 ^= 1;
    }
    return task;
}
