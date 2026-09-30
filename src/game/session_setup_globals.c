#include "../../include/session_setup_internal.h"

void func_8002ECC4(SessionSetupCommand *command)
{
    int value0;
    int value1;
    int value2;

    value0 = command->argument0;
    value1 = command->argument1;
    value2 = command->argument2;
    D_800AD134 = value0;
    D_800AD130 = value1;
    D_800AD12C = value2;
}
