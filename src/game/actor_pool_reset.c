#include "../../include/actor.h"

extern GameActor D_800A4628[200];
extern GameActor *D_800AA708;

void func_8002818C(void)
{
    int i;

    for (i = 0; i < 200; i++) {
        D_800A4628[i].kind = 11;
    }
    D_800AA708 = 0;
}
