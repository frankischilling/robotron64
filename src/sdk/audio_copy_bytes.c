void func_8006F3C0(unsigned char *source, unsigned char *destination, int count)
{
    unsigned char *read;
    unsigned char *write;
    int index;

    read = source;
    write = destination;
    for (index = 0; index < count; index++) {
        *write++ = *read++;
    }
}
