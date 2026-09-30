#include "../../include/session_setup_internal.h"

void func_8002EDB0(SessionSetupCommand *command)
{
    int speed;

    if (D_80077AD0->type == 8) {
        speed = D_800AD118 * 120 / 100;
    } else {
        speed = command->argument0 * D_800AD118 / 100;
    }
    D_80077AD0->value50 = speed;
}
