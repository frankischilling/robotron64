extern int D_800C8B70;

int func_800391C0(int index)
{
    if (index >= D_800C8B70) {
        D_800C8B70 = index + 1;
    }
    return index;
}

void func_800391E8(int unused)
{
}

short func_800391F0(int unused0, short *value, int unused2, int unused3)
{
    return *value;
}

int func_80039208(int unused0, int value, int unused2, int unused3)
{
    return value;
}
