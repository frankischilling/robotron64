int func_8004CDE8(void);

int func_8000A21C(int first, int second)
{
    if (first < second) {
        return func_8004CDE8() % (second - first) + first;
    } else {
        return func_8004CDE8() % (first - second) + second;
    }
}
