#include "../../include/game_hud_state.h"
#include "../../include/early_game_state.h"

void func_800371FC(void)
{
    GamePlayerState *player;
    int level;
    SavedPlayerState second;
    int players;
    /* Retail leaves this word uninitialized in single-player mode. */
    int secondPowers;

    second.value18 = 0;
    second.value24 = 0;
    second.active = 0;
    second.field70 = 0;
    second.field74 = 0;
    /* Keeping these initializations together preserves the IDO delay slot. */
    second.field6C = 0, players = 1;
    if (D_800AD164 == 2) {
        player = D_8009B190;
        second.value18 = D_8009B190[1].saved.value18;
        second.active = D_8009B190[1].saved.active;
        second.field70 = D_8009B190[1].saved.field70;
        second.field74 = D_8009B190[1].saved.field74;
        second.field6C = D_8009B190[1].saved.field6C;
        secondPowers = D_8009B190[1].saved.unknown00[1];
        players = 2;
        if (D_800AD168 == 0) {
            if (D_8009CCB4 <= 0) second.value24 = 1;
            else second.value24 = D_8009CCB4;
            level = D_800B9A78.valueCD0;
        } else {
            if (D_8009BF00 <= 0) level = 1;
            else level = D_8009BF00;
            second.value24 = D_800B9A78.valueCD0;
        }
    } else {
        player = &D_8009B190[D_800AD168];
        level = D_800B9A78.valueCD0;
    }
    if (D_800AD284 == 0 && D_800B9A78.resourceCD4 == -1 &&
        (D_800AD288 == 3 || D_800AD288 == 4)) {
        if (D_800AD1C8 == 0) {
            func_8004B590(player->saved.value18, level, player->saved.active,
                player->saved.field70, player->saved.field74,
                player->saved.field6C, player->saved.unknown00[1],
                second.value18, second.value24, second.active, second.field70,
                second.field74, second.field6C, secondPowers, players);
        } else {
            func_8004B590(player->saved.value18,
                D_800AD1B8->value10[0], player->saved.active,
                player->saved.field70, player->saved.field74,
                player->saved.field6C, player->saved.unknown00[1],
                second.value18, second.value24, second.active, second.field70,
                second.field74, second.field6C, secondPowers, players);
        }
    }
}
