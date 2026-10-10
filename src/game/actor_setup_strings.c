#include "../../include/actor_setup_internal.h"

void func_8001DE60(int value)
{
    unsigned char *text;

    D_800B8F74 = 10;
    func_80000518(D_80074AA4);
    func_80000518(D_80074ACC);

    D_800AD2D8.flags12.bits.mode = value;
    D_800AD2C8[0] = -1;
    D_800AD2C8[1] = -1;
    D_800AD2D8.flags12.value &= 0xFF7F;

    text = D_80074AA4;
    text[func_8003B4FC(text) - 3] = 0x3B;
    text[func_8003B4FC(text) - 2] = 0x26;
    text[func_8003B4FC(text) - 1] = 0x95;

    text = D_80074ACC;
    text[func_8003B4FC(text) - 3] = 0x3B;
    text[func_8003B4FC(text) - 2] = 0x26;
    text[func_8003B4FC(text) - 1] = 0x95;
}

unsigned char D_80074AA4[] = "abcdefghijklmnopqrstuvwxyz0123456789SDE";
unsigned char D_80074ACC[] = "bcdfghjklmnpqrstvwxyz0123456789SDE";
