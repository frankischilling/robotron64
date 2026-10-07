#ifndef ROBOTRON_GAME_HUD_STATE_H
#define ROBOTRON_GAME_HUD_STATE_H

#include "save_game.h"

/* Views into the source-owned player and session records. */
extern int D_8009BF00;
extern int D_8009CCB4;
extern int D_800AD164;
extern int D_800AD168;
extern struct EarlyGameActor *D_800AD1B8;
extern int D_800AD1C8;
extern int D_800AD288;

void func_800371FC(void);
void func_8004B590(int score, int level, int lives, int value3, int value4,
    int value5, int powers, int secondScore, int secondLevel, int secondLives,
    int value10, int value11, int value12, int value13, int players);

#endif
