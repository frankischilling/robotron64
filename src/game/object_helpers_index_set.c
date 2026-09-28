#include "../../include/object.h"

extern int func_80039CD0(int);

int func_80039D4C(int object, int value)
{
    if (value >= func_80039CD0(object)) {
        return 0;
    }

    return D_800BF918[object].index02 = value;
}
