#include "../../include/graphics_state_internal.h"

void func_80045124(unsigned int first, unsigned int second, unsigned int third, unsigned int fourth)
{
    D_80123B14++;
    D_80123B18++;
    FRAME_COMMAND(0x0400040F, first);
    FRAME_COMMAND(0x0402040F, second);
    FRAME_COMMAND(0x0404040F, third);
    FRAME_COMMAND(0x0406040F, fourth);
    FRAME_COMMAND(0xBF000000, 0x00000204);
    FRAME_COMMAND(0xBF000000, 0x00060004);
}
