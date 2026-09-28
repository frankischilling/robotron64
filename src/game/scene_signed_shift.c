int func_800338CC(int value, int shift)
{
    int sign;

    sign = 1;
    if (value < 0) {
        value = -value;
        sign = -1;
    }
    value >>= shift;
    return value * sign;
}
