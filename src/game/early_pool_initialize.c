#include "../../include/game_memory.h"

extern int D_800AE300[2];
extern unsigned char D_800AE308[72];
extern unsigned char D_800AE350[72];
extern int D_800972B0;

void func_8000D38C(void)
{
    D_800AE300[0] = 1;
    D_800AE300[1] = 0;
    D_800972B0 = 1;
    func_8003B694(D_800AE308, 0, 72);
    func_8003B694(D_800AE350, 0, 72);
}
