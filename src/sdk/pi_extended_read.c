#include "../../include/sdk_pi_word.h"

int func_8006E650(SdkPiWordHandle *handle, unsigned int address, unsigned int *word)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA4600010;
    while (status & 3) {
        status = *(volatile unsigned int *)0xA4600010;
    }
    *word = *(volatile unsigned int *)(handle->baseAddress | address | 0xA0000000);
    return 0;
}
