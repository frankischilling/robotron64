#include "../../include/sdk_si.h"

int func_8006DBF0(void)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA4800018;
    if (status & 3) {
        return 1;
    }
    return 0;
}
