#include "../../include/controller_services.h"

void func_8004F178(int port)
{
    D_80143418.port = port;
    D_80143418.operation = 1;
    func_800635A0(&D_80141210, &D_80143418, 1);
}

void func_8004F1B4(int port)
{
    D_80143418.port = port;
    D_80143418.operation = 0;
    func_800635A0(&D_80141210, &D_80143418, 1);
}
