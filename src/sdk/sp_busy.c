#include "../../include/sdk_io.h"

int func_8006B3F0(void)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA4040010;
    if (status & 0x1C) {
        return 1;
    }
    return 0;
}
