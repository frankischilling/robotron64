#include "../../include/session_setup_internal.h"

void func_8002F1DC(SessionSetupCommand *command)
{
    int name;

    name = command->argument0;
    if (!D_80077AD0->flags04.bits.loaded) {
        if (D_80077AD0->value22 != -1) {
            func_8001C0D0(D_80093E38);
        }
        D_80077AD0->value22 = name;
    }
}
