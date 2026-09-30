#include "../../include/object.h"

extern int D_8007A1CC[][4];
extern void func_8004BD00(int, int, int);

int func_80039CD0(int object)
{
    int value = D_800BF918[object].unknown0C[2];
    int result;

    if (value >= 255 || value < 0) {
        return 1;
    }

    func_8004BD00(-1, value, 0);
    result = D_8007A1CC[value][0];
    if (result == 0) {
        result = 1;
    }
    return result;
}
