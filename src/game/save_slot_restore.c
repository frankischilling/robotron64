#include "../../include/save_game.h"
#include "../../include/game_memory.h"

void func_8002FFC8(SavedGameSlot *slot)
{
    int player;

    for (player = 0; player < 2; player++) {
        /* The target copies the live record's full size from each saved prefix. */
        func_8003B520(&D_8009B190[player], &slot->players[player], sizeof(GamePlayerState));
    }
    func_8003B520(&D_800AD138, slot, sizeof(SavedSessionState));
    func_8002FF40(&slot->options);
}
