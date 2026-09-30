extern int D_8008D510;

void func_8004F960(int interval)
{
    if (interval < 0) {
        D_8008D510 = -interval;
    } else {
        D_8008D510 = interval;
    }
}
