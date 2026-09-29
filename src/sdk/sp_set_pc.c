#include "../../include/sdk_io.h"

int func_8006B320(unsigned int pc)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA4040010;
    if ((status & 1) == 0) {
        return -1;
    }
    *(volatile unsigned int *)0xA4080000 = pc;
    return 0;
}
