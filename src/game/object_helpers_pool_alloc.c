#include "../../include/object.h"
#include "../../include/object_helpers.h"
#include "../../include/object_draw.h"

extern int D_800C8B7C;

int func_8003A2F8(int object, int value00, int value0E, int unused3,
                  int unused4, int value16)
{
    ObjectRecord *record;
    int i;

    if (object < 0) {
        if (value00 == 0 && D_800C86C0[0] == 0) {
            func_8003A3F8(0);
        }
        for (i = 1; i != 300; i++) {
            if (D_800C86C0[i] != 0) {
                break;
            }
        }
        object = i;
    }

    if (object < 300) {
        D_800C8B7C++;
    } else {
        return -1;
    }

    func_8003A460(object);
    record = &D_800BF918[object];
    record->unknown0C[1] = 0;
    record->unknown0C[4] = 0;
    record->unknown00 = value00;
    record->unknown0C[2] = value0E;
    D_800C86C0[object] = 0;
    record->value16 = value16;
    record->index02 = 1;
    return object;
}
