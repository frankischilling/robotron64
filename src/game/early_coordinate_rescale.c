void func_8000DFB0(int *x, int *y)
{
    int first = *x;
    int second = *y;

    second -= 100;
    second *= 320;
    first -= 100;
    first *= 320;
    *x = first;
    *y = second;
}
