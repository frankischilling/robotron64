#include "../../include/session_setup_internal.h"

void func_8002F128(SessionSetupCommand *command)
{
    int model;
    int scale;

    model = command->argument0;
    scale = command->argument1;
    if (!D_80077AD0->flags04.bits.loaded) {
        if (D_80077AD0->value1E != -1) {
            func_8001C0D0(D_80093E1C);
        }
        D_80077AD0->value1E = model;
        D_80077AD0->value0C = scale;
    }
}
