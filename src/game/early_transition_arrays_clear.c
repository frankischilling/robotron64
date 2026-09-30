extern int D_800972C0;
extern short D_800972C8[8];
extern short D_80097318[8];
extern short D_80097328[8];
extern int D_800972F8[8];

void func_8000E328(void)
{
    int i;

    D_800972C0 = 0;
    for (i = 0; i < 8; i++) {
        D_800972C8[i] = 0;
        D_80097318[i] = 0;
        D_80097328[i] = 0;
        D_800972F8[i] = 0;
    }
}
