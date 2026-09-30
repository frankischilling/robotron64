#include "../../include/object.h"
#include "../../include/object_draw.h"

extern int D_8007A1CC[][4];

unsigned char func_800393DC(int object)
{
    return D_800BF918[object].unknown14[0];
}

unsigned char func_800393FC(int object)
{
    return D_800BF918[object].unknown14[1];
}

int func_8003941C(int index)
{
    return D_8007A1CC[index][0];
}

void func_80039434(int object, int value)
{
    D_800BF918[object].unknown14[0] = value;
}

void func_80039450(int unused0, int unused1)
{
}

int func_8003945C(int object, int value)
{
    D_800BF918[object].unknown0C[2] = value;
    return (unsigned char)value;
}

int func_8003947C(int object, int frame)
{
    ObjectRecord *record;

    record = &D_800BF918[object];
    record->unknown0C[0] = frame;
    record->unknown0C[2] = record->model->frames[frame]->frame;
    record->index02 = 1;
    return 1;
}
