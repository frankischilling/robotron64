#include "../../include/save_game.h"

extern int D_80073850[];
extern int D_80073864[];

int func_800126E0(void)
{
    int i = 0;

    while (D_80073864[i] != 0) {
        if (D_80073864[i] ==
            D_8009B190[D_800AD138.saved.currentPlayer].saved.selection05) {
            return D_80073850[i];
        }
        i++;
    }
}
