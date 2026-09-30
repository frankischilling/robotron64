#include "../../include/object.h"
#include "../../include/object_helpers.h"
#include "../../include/object_draw.h"

extern int D_800781E0;
extern int D_800781EC;
extern int D_800C8B7C;

int func_8003A2F8(int object, int value00, int value0E, int unused3,
                  int unused4, int value16);

int func_8003921C(int type, int count, ObjectDrawResource *draw,
                  ObjectModel *model)
{
    int object;
    ObjectRecord *record;

    if (D_800781E0 >= 251) {
        return -1;
    }
    object = func_8003A2F8(-1, type, 0, 0, 1, count);
    record = &D_800BF918[object];
    record->property12 = 0;
    record->drawResource = draw;
    record->unknown0C[3] = type;
    record->model = model;
    if (object >= 0) {
        D_800781EC += count;
    }
    D_800781E0++;
    return object;
}

void func_800392F4(int object)
{
    if (D_800C86C0[object] == 0) {
        D_800781EC -= D_800BF918[object].value16;
    }
    func_8003A3F8(object);
}

void func_80039358(void)
{
    int object;

    for (object = 0; object < 300; object++) {
        D_800C86C0[object] = 1;
        if (D_800C8B7C > 0) {
            D_800C8B7C--;
        }
    }
    D_800781E0 = 0;
}
