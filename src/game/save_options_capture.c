#include "../../include/save_game.h"
#include "../../include/game_memory.h"

void func_8002FE00(SavedOptions *options)
{
    func_8003B520(options, &D_800AD2F8, 0x18);
    options->audio1C = D_800AD314;
    options->audio18 = D_800AD310;
    options->playerField34[0] = D_8009B190[0].saved.field34;
    options->playerField34[1] = D_8009B190[1].saved.field34;
}
