#include "../../include/session_setup_internal.h"

void func_8002ED50(SessionSetupCommand *command)
{
    D_80077AD0->flags04.bits.flag13 = command->argument0;
}
