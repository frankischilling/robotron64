#include "../../include/graphics_state_internal.h"

void func_800464F4(void)
{
    FRAME_COMMAND(0xB8000000, 0);
}

void func_80046518(FrameCommand *list)
{
    FRAME_COMMAND(0x06000000, list);
}
