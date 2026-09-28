#include "../../include/session_setup_internal.h"

void func_8002EFD8(SessionSetupCommand *command)
{
    int state;

    state = command->argument0;
    if (!D_80077AD0->flags04.bits.loaded) {
        D_800AC970++;
        if (D_800AC970 >= 550) {
            func_8001C0D0(D_80093DD4);
        }
        D_80077AD0->entries[state] = D_800AA710 + D_800AC970 - 1;
        func_8003B694(D_800AA710 + D_800AC970 - 1, -1,
                     sizeof(SessionSetupAnimation));
    }
}
