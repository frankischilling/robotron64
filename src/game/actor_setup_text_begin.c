#include "../../include/game_memory.h"
#include "../../include/save_game.h"
#include "../../include/text.h"

extern int D_8009EFA0;
extern int D_800AD2D0;

void func_8001EB2C(void);

void func_8001EAE8(void)
{
    func_8003BCC4(D_80075D88);
    func_80000518(D_80075D88);
    D_800AD2D0 = D_8009EFA0;
    func_8001EB2C();
}
