#include "../../include/controller_input.h"

extern int D_800CA570;
extern int D_800CA574;

int func_8003C4C8(void)
{
    int value;

    if (D_8013DBD8[0] & 0x2000) {
        value = (D_8013DBC8[0] << 11) / 80;
        D_800CA570 = value;
        D_800CA574 = value;
    }
    return D_800CA570;
}

int func_8003C514(void)
{
    if (D_8013DBD8[0] & 0x2000) {
        D_800CA570 = (D_8013DBC8[0] << 11) / 80;
        D_800CA574 = (D_8013DBB8[0] << 11) / 80;
    }
    return D_800CA574;
}
