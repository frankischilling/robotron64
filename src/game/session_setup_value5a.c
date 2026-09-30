#include "../../include/session_setup_internal.h"

void func_8002F49C(SessionSetupCommand *command)
{
    int value;

    value = command->argument0;
    D_80077AD0->value58.halves.low = value;
}
