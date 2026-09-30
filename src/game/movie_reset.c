#include "../../include/movie.h"
#include "../../include/game_memory.h"

extern int D_800B1BE0;

void func_80002EE0(void)
{
    D_800B1BE0 = 0;
    func_8003B694(D_800B00B8, 0, sizeof(D_800B00B8));
    func_8003B694(&D_800B14B0, 0, sizeof(D_800B14B0));
}
