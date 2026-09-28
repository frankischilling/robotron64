#include "../../include/controller_input.h"

int func_8003C180(void)
{
    if (D_8013DBD8[0] & 0x2000) {
        return 1;
    }
    return 0;
}
