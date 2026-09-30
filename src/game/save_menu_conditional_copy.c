void func_80021C14(int **destination, int *enabled, unsigned char *source)
{
    if (*enabled != 0) {
        **destination = source[1];
    }
}
