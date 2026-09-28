#include "../../include/session_setup_internal.h"

void func_8002ED78(SessionSetupCommand *command)
{
    int value;
    int limit;

    value = command->argument0;
    limit = command->argument1;
    D_80077AD0->value08 = value;
    D_80077AD0->value10 = limit;
}
