#include "../../include/object.h"

int func_80039DAC(int object)
{
    return D_800BF918[object].index02;
}

int func_80039DCC(int object, int value)
{
    D_800BF918[object].unknown14[1] = value;
    return (unsigned char)value;
}

int func_80039DEC(int object)
{
    return D_800BF918[object].unknown14[1];
}

int func_80039E0C(int object, int value)
{
    return 0;
}

int func_80039E1C(int object, int value)
{
    D_800BF918[object].unknown0C[4] = value;
    return (unsigned char)value;
}

int func_80039E3C(int object)
{
    return D_800BF918[object].enabled13;
}

int func_80039E5C(int object, int value)
{
    ObjectRecord *record = &D_800BF918[object];
    record->enabled13 = value;
    return record->enabled13;
}

void func_80039E80(int object, unsigned char value)
{
    D_800BF918[object].unknown0C[5] = value;
}
