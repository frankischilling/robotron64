#include "../../include/save_game.h"
#include "../../include/game_memory.h"
#include "../../include/audio_game.h"

void func_8002FF40(SavedOptions *options)
{
    func_8003B520(&D_800AD2F8, options, 0x18);
    D_800AD314 = options->audio1C;
    D_800AD310 = options->audio18;
    D_8009B190[0].saved.field34 = options->playerField34[0];
    D_8009B190[1].saved.field34 = options->playerField34[1];
    func_8001A2C4();
    func_80051888(D_800AD314);
    func_80051854(D_800AD310);
}
