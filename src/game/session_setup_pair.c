#include "../../include/session_setup_internal.h"

void func_8002F414(SessionSetupCommand *command)
{
    SessionSetupPair pair;

    pair.first = command->argument0;
    pair.second = command->argument1;
    D_80077AD0->value58.pair = pair;
}
