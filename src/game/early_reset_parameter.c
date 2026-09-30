#include "../../include/early_session_state.h"

EarlyGamePosition D_800736AC = {{20000, 20000, 0}};
extern int D_800AD1C8;

void func_80010460(int enabled)
{
    EarlyGamePosition position = D_800736AC;

    if (enabled != 0) {
        D_800AD1C8 = 0;
    }
}
