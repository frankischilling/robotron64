int func_8004B2E0(int value, unsigned char *digits)
{
    int count;
    unsigned char *output;
    int radix;

    count = 0;
    if (value < 0) {
        value = 0;
    }
    output = digits;
    radix = 10;
    do {
        count++;
        *output++ = value % radix;
        value /= radix;
    } while (value != 0);
    return count;
}
