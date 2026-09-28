extern short D_800A3AD8[];
extern unsigned char D_8009FC50[];

unsigned char *func_800383C4(int identifier)
{
    int offset = D_800A3AD8[identifier];

    if (offset != -1) {
        return D_8009FC50 + offset;
    }
    return 0;
}
