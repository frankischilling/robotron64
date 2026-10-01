#include "../../include/object.h"
#include "../../include/object_helpers.h"

extern char D_800ACDC0[];

int func_80039C78(int value, int unused1, int unused2, int unused3)
{
    if (D_800C86C0[0] != 0) {
        func_8003921C(0, 0, 0, (ObjectModel *)D_800ACDC0);
    }
    return value;
}

int func_80039CC4(int unused)
{
    return 1;
}
