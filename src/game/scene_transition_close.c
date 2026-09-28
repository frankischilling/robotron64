#include "../../include/pak_file.h"
#include "../../include/save_game.h"
#include "../../include/save_menu_internal.h"

extern unsigned char D_800941A4[];
extern int D_800BEF50;

void func_80032880(void)
{
    func_8001C49C(D_800941A4);
    if (D_800AD284 != 3) {
        D_800AD284 = 3;
        D_800BEF50 = D_8009EFA4;
        func_8003614C(0x16, 0, 1, 0);
    }
}
