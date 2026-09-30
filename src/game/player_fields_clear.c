#include "../../include/save_game.h"

void func_80032D00(void)
{
    int index;

    for (index = 0; index < 2; index++) {
        D_8009B190[index].saved.active = 0;
        D_8009B190[index].saved.actor08 = 0;
    }
}
