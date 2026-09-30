#include "../../include/pak_file.h"
#include "../../include/save_game.h"
#include "../../include/save_menu_internal.h"

extern unsigned char D_80094190[];
extern int D_800BEF50;

void func_80032830(void)
{
    func_8001C49C(D_80094190);
    func_8003614C(0x15, 0, 1, 0);
    D_800AD284 = 1;
    D_800BEF50 = D_8009EFA4;
}
