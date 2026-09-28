#include "../../include/session_setup_internal.h"

void func_8002EE24(SessionSetupCommand *command)
{
    int value;

    value = command->argument0;
    D_80077AD0->value16 = value;
}
