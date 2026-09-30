#include "../../include/model_geometry_internal.h"

extern int D_800CD3B8;
int func_80047048(void);
void func_80047094(int count);
void func_80040724(int x, int y);

void func_80040560(int amount)
{
    int x;
    int y;
    int count;
    int first;

    D_800CD3B8 = 31000 - amount * 10000;
    FRAME_COMMAND(0xB7000000, 4);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFCF279);
    FRAME_COMMAND(0xB900031D, 0x00552078);
    FRAME_COMMAND(0xBA000C02, 0);
    FRAME_COMMAND(0xBA001001, 0);
    FRAME_COMMAND(0xBA001301, 0);
    FRAME_COMMAND(0xBB000001, 0x80008000);
    FRAME_COMMAND(0xBA000E02, 0);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        x = 0;
        first = D_80123AE4;
        for (; x < 320; x += 160) {
            for (y = 0; y < 240; y += 6) {
                func_80040724(x, y);
            }
        }
        count = D_80123AE4 - first;
        func_80047094(count);
    }
}
