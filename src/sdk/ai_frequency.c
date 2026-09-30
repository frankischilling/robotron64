extern int D_8008E3B8;

int func_80065950(unsigned int frequency)
{
    register unsigned int divider;
    register unsigned char bitRate;
    register float ratio;

    ratio = (float)D_8008E3B8 / frequency + 0.5f;
    divider = ratio;
    if (divider < 132) {
        return -1;
    }
    bitRate = divider / 66;
    if (bitRate > 16) {
        bitRate = 16;
    }
    *(volatile unsigned int *)0xA4500010 = divider - 1;
    *(volatile unsigned int *)0xA4500014 = bitRate - 1;
    *(volatile unsigned int *)0xA4500008 = 1;
    return D_8008E3B8 / (int)divider;
}
