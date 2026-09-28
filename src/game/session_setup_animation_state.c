#include "../../include/session_setup_internal.h"

void func_8002F098(SessionSetupCommand *command)
{
    int index;
    int state;

    index = command->argument0;
    if (!D_80077AD0->flags04.bits.loaded) {
        state = D_80075954[index];
        (D_800AA710 + D_800AC970 - 1)->playback.frameIndex = state;
        D_80077AD0->flags04.bits.states |= 1 << state;
    }
}
