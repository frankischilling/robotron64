#include "../../include/save_game.h"
#include "../../include/game_memory.h"

void func_8002FE68(SavedGameSlot *slot)
{
    int player;

    D_8009B190[D_800AD138.currentPlayer].level = D_800AD138.level;
    for (player = 0; player < 2; player++) {
        func_8003B520(&slot->players[player], &D_8009B190[player], sizeof(SavedPlayerState));
        slot->playerLevels[player] = D_8009B190[player].level;
    }
    func_8003B520(slot, &D_800AD138, sizeof(SavedSessionState));
    func_8002FE00(&slot->options);
}
