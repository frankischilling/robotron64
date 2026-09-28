#include "../../include/session_menu_internal.h"

void func_8002F9D4(void)
{
    D_800B8F64 = 0;
    func_8002836C();
    func_8001F8E8(0, 0, 10, 0, 0);
    func_8003C5F4(0);
    func_80048D70();
    func_80022528(D_8009CD10, 2, 1);
}

void func_8002FA34(int *selection)
{
    D_800AD280 = 5;
    func_800278AC(1, 1, func_8002F9D4);
}
