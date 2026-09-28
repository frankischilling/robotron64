#include "../../include/object_helpers.h"

extern int D_800C8B7C;
extern int D_800781E0;

int func_8003A3F8(int object)
{
    if (object >= 0 && object < 300 && D_800C86C0[object] == 0) {
        D_800C86C0[object] = 1;
        D_800C8B7C--;
        D_800781E0--;
        return 1;
    }
    return 0;
}
