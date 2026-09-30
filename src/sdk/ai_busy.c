#include "../../include/sdk_io.h"

int func_8006B5B0(void)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA450000C;
    if (status & 0x80000000U) {
        return 1;
    }
    return 0;
}
