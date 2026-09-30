typedef struct EarlySelectionPair {
    int value;
    int active;
} EarlySelectionPair;

extern EarlySelectionPair D_80097630;
extern int D_8009EFA0;

void func_8001A528(void)
{
    D_80097630.value = D_8009EFA0;
    D_80097630.active = 1;
}
