#include "../../include/session_setup_internal.h"

void func_8002F464(SessionSetupCommand *command)
{
    int value;

    value = command->argument0;
    D_80077AD0->value64 = value;
    if (D_80077AD8 < value) {
        D_80077AD8 = value;
    }
}
