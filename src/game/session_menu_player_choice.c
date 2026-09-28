#include "../../include/session_menu_internal.h"

void func_8002FB54(int *selection)
{
    func_8003614C(22, 0, 1, 0);
    func_800278AC(0, 1, 0);
    func_8003BF64(0);
    D_800AD284 = 0;
    if (D_80077B1C != D_8009B190[D_800AD168].saved.selection05) {
        D_80073888 = 1;
        D_80073890 = 20;
        D_8009B190[D_800AD168].saved.selection05 = D_80077B1C;
    }
}
