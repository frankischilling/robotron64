#include "../../include/sdk_io.h"

void func_8006AFF0(unsigned int status)
{
    *(volatile unsigned int *)0xA4040010 = status;
}
