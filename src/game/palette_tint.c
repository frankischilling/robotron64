extern int D_8007D5DC, D_8007D5E0, D_8007D5E4;

void func_80046DD0(int index);

void func_800465B0(int red, int green, int blue)
{
    int index;

    D_8007D5DC = red;
    D_8007D5E0 = green;
    D_8007D5E4 = blue;
    for (index = 0; index < 256; index++) {
        func_80046DD0(index);
    }
}
