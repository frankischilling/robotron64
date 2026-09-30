extern unsigned int D_80000308;

int osPiRawReadIo(unsigned int address, unsigned int *word)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA4600010;
    while (status & 3) {
        status = *(volatile unsigned int *)0xA4600010;
    }
    *word = *(volatile unsigned int *)(D_80000308 | address | 0xA0000000);
    return 0;
}
