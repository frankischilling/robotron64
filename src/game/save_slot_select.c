#include "../../include/save_game.h"
#include "../../include/game_memory.h"

void func_800305F8(int *selection)
{
    int player;
    int start;
    int end;
    int step;
    GamePlayerState *state;
    int *selectedSlot;

    if (D_800AD318.data.occupied[*selection] != 0) {
        func_800278AC(0, 1, 0);
        func_8002FFC8(&D_800AD318.data.slots[*selection]);
        if (D_800AD284 != 0) {
            func_8003BF64(0);
            D_800AD284 = 0;
        }
        D_800AD280 = 9;
        end = 2;
        start = 0;
        if (D_800AD138.saved.currentPlayer == 0) {
            start = 1;
            end = -1;
            step = -1;
        } else {
            step = 1;
        }
        for (player = start; player != end; player += step) {
            state = &D_8009B190[player];
            if (state->saved.active == 0) {
                continue;
            }
            selectedSlot = selection;
            D_800AD138.saved.level =
                D_800AD318.data.slots[*selectedSlot].playerLevels[player];
            state->level = D_800AD138.saved.level;
            func_800214D4(1);
            func_8003B520(state->unknownA0, &D_800B9A78, 0xD14);
        }
    }
}
