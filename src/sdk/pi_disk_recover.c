#include "../../include/sdk_pi_disk.h"

extern unsigned int D_8008E3C0;
void func_8006E3AC(void);

void func_8006E2C4(void)
{
    SdkPiTransferPrefix *transfer;
    volatile unsigned int status;

    transfer = &D_80196404->transfer;
    status = *(volatile unsigned int *)0xA4600010;
    while (status & 3) {
        status = *(volatile unsigned int *)0xA4600010;
    }
    *(volatile unsigned int *)0xA5000510 = transfer->bufferManagerShadow | 0x10000000;
    status = *(volatile unsigned int *)0xA4600010;
    while (status & 3) {
        status = *(volatile unsigned int *)0xA4600010;
    }
    *(volatile unsigned int *)0xA5000510 = transfer->bufferManagerShadow;
    func_8006E3AC();
    *(volatile unsigned int *)0xA4600010 = 2;
    D_8008E3C0 |= 0x100401;
}
