#include "../../include/frame.h"
#include "../../include/fixed_math.h"

extern int D_8007D8F4;
extern unsigned short D_8007D6D0[];
extern FixedMatrix D_800CD250;

void func_80048460(void);

#ifndef ROBOTRON_FRAME_FATAL_CONTEXT
void func_80048B8C(void *output, int *position)
{
    int relative[3];

    relative[0] = (position[0] - D_800C8BD8.position[0]) >> 1;
    relative[1] = (position[1] - D_800C8BD8.position[1]) >> 1;
    relative[2] = (position[2] - D_800C8BD8.position[2]) >> 1;
    func_8004D4B4(output, &D_800CD250, relative);
}

void func_80048BF8(void)
{
    FRAME_COMMAND(0xBA000C02, 0x2000);
    FRAME_COMMAND(0xBA000E02, 0x8000);
    FRAME_COMMAND(0xFD100000, D_8007D6D0);
    FRAME_COMMAND(0xE8000000, 0);
    FRAME_COMMAND(0xF5000100, 0x07000000);
    FRAME_COMMAND(0xE6000000, 0);
    FRAME_COMMAND(0xF0000000, 0x073FC000);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xBB000001, 0x80008000);
    FRAME_COMMAND(0xBA001001, 0x10000);
    FRAME_COMMAND(0xB900031D, 0x00553078);
    FRAME_COMMAND(0xB7000000, 0x2005);
}

void func_80048D70(void)
{
    func_80048460();
}
#endif

void func_80048D90(int value)
{
    D_8007D8F4 = value;
}

void func_80048D9C(void)
{
    func_8004DB34(&D_800CD250);
}
