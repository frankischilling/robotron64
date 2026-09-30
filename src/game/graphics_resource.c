#include "../../include/graphics_state_internal.h"

static const unsigned char D_800951C8[] = "textures\\ROBO64.TGA";

void func_8004653C(int unused)
{
    D_80123AEC = func_8004DD6C(0x25FD0);
    func_8004EE9C((unsigned char *)D_800951C8, D_80123AEC);
}

void func_80046580(void)
{
    func_8004DC70(D_80123AEC);
    D_80123AEC = 0;
}
