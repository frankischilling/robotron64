#include "../../include/sdk_si.h"

extern unsigned int D_8008F250;
extern OSMesg D_80196470[1];
extern OSMesgQueue D_80196478;

void func_800699C0(void)
{
    D_8008F250 = 1;
    osCreateMesgQueue(&D_80196478, D_80196470, 1);
    func_800635A0(&D_80196478, 0, 0);
}

void func_80069A10(void)
{
    OSMesg token;

    if (!D_8008F250) {
        func_800699C0();
    }
    func_80062240(&D_80196478, &token, 1);
}

void func_80069A54(void)
{
    func_800635A0(&D_80196478, 0, 0);
}
