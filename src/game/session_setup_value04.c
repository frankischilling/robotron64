#include "../../include/session_setup_internal.h"

void func_8002ECEC(SessionSetupCommand *command)
{
    int value;

    value = command->argument0;
    D_80077AD0->flags04.fields.value04 = value;
}
