#include "../../include/resource_strings.h"

int func_800383F8(unsigned char *name)
{
    int index;

    if (name != 0) {
        for (index = 0; index < D_800A42A8; index++) {
            if (func_8003B7FC(&D_8009FC50[D_800A3AD8[index]], name) == 0) {
                return index;
            }
        }
    }
    return -1;
}
