#include "../../include/frame.h"

extern unsigned short D_8013D950;
extern int D_8007D914;
extern void *D_8013823C;

void func_80049514(void)
{
    FRAME_COMMAND(0xBC00000E, D_8013D950);
    FRAME_COMMAND(0x01030040, (unsigned int)D_8013823C + (D_8007D914 << 6) + 0x80000000);
    FRAME_COMMAND(0x01010040, (unsigned int)D_8013823C + (D_8007D914 << 6) + 0x80000080);
}
