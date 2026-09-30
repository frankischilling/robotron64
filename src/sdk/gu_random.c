int func_800631F0(void)
{
    static unsigned int D_8008F120 = 174823885;
    unsigned int value;

    value = (D_8008F120 << 2) + 2;
    value *= value + 1;
    value >>= 2;
    D_8008F120 = value;
    return value;
}
