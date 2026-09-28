#include "../../include/controller_services.h"

void func_8004EFB0(void)
{
    D_8008D504 = 1;
    osCreateMesgQueue(&D_80143428, &D_80143424, 1);
    func_800635A0(&D_80143428, 0, 0);
}

void func_8004F000(void)
{
    OSMesg message;

    if (D_8008D504 == 0) {
        func_8004EFB0();
    }
    func_80062240(&D_80143428, &message, 1);
}

void func_8004F040(void)
{
    func_800635A0(&D_80143428, 0, 0);
}
