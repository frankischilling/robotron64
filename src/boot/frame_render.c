#include "../../include/frame.h"
#include "../../include/graphics_tasks.h"

extern int D_80097640;
extern int D_8007D918;
extern int D_8007D914;
extern int D_8007D8EC;
extern GraphicsTask D_8013D8A0[];

void func_80060720(void);

void func_800489F4(void)
{
    FrameCommand *start;
    GraphicsTask *task;

    if (D_80097640) {
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xF9000000, 0xFFFFFFFF);
        FRAME_COMMAND(0xEE000000, 0xFFFFFFFF);
        FRAME_COMMAND(0xB9000201, 4);
        FRAME_COMMAND(0xB900031D, 0x0FA54040);
        FRAME_COMMAND(0xF64FC3BC, 0);
    }
    FRAME_COMMAND(0xE9000000, 0);
    FRAME_COMMAND(0xB8000000, 0);
    func_80060720();
    if (D_8007D918 == 0) {
        D_8007D918 = 1;
    } else {
        func_80050084();
    }
    task = &D_8013D8A0[D_8007D914];
    func_8005018C(task, start = D_80138278,
                 (unsigned int)D_80138254 - (unsigned int)D_80138278,
                 D_8007D8EC, 0x40);
}
