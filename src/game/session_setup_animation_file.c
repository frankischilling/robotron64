#include "../../include/session_setup_internal.h"

void func_8002F1A4(SessionSetupCommand *command)
{
    int name;

    name = command->argument0;
    if (!D_80077AD0->flags04.bits.loaded) {
        (D_800AA710 + D_800AC970 - 1)->playback.field02 = name;
    }
}
