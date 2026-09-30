#include "../../include/session_menu_internal.h"

void func_8002FA70(void)
{
    func_80022528(D_8009CD10, 2, 3);
}

void func_8002FA9C(int *selection)
{
    D_800B8F64 = 0;
    D_800AD280 = 5;
    func_800278AC(1, 1, func_8002FA70);
}
