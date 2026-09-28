#include "../../include/session_menu_internal.h"

void func_8002FD20(int *selection)
{
    func_8002FD44(1);
}

void func_8002FD44(int refreshSelection)
{
    D_800AD314 = D_800AEE94;
    D_800AD310 = D_800AEE90;
    func_80051888(D_800AD314);
    func_80051854(D_800AD310);
    D_800AD2F8.field04 = 1;
    D_800AD2F8.field0C = 4;
    D_800AD2F8.field08 = 1;
    D_800AD2F8.field10 = 25000;
    D_800AD2F8.field14 = D_8009CD0C;
    D_8009B190[0].saved.field34 = 0;
    D_8009B190[1].saved.field34 = 0;
    if (refreshSelection != 0) {
        func_80025C40(D_80076FC8);
    }
    func_8001A2C4();
}
