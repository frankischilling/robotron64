#include "../../include/session_setup_internal.h"

void func_8002ED00(SessionSetupCommand *command)
{
    D_80077AD0->value14 = command->argument0 << 8;
    if (D_80077AD0->type == 8) {
        D_80077AD0->value14 = 0x6400;
    }
}
