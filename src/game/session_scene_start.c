#include "../../include/save_game.h"

extern int D_8009E57C;
extern int D_80075FFC;
extern int D_80075FD0[];
extern int D_800BA7A0;
extern unsigned char D_800922AC[];
extern unsigned char D_800922BC[];
extern unsigned char D_800922C8[];
extern unsigned char D_800922DC[];
extern unsigned char D_800922FC[];
int func_800360B8(unsigned char *label);
void func_80032D00(void);
void func_80032D28(int player, int initializeOnly, int offset);

void func_80022528(int level, int mode, int extra)
{
    int index;
    GamePlayerState *players;

    func_800360B8(D_800922AC);
    if (mode == 0) {
        mode++;
        if (D_8009E57C == 0) {
            level = D_80075FD0[D_80075FFC];
            if ((unsigned int)++D_80075FFC >= 11U) {
                D_80075FFC = 0;
            }
        } else {
            level = D_80075FFC++;
            D_80075FFC %= D_800BA7A0;
        }
        D_800AD280 = 6;
    } else {
        D_800AD280 = 9;
    }
    D_800AD138.saved.level = level;
    D_800AD138.saved.extra48 = extra;
    func_800360B8(D_800922BC);
    func_800360B8(D_800922C8);
    func_80032D00();
    D_800AD138.saved.mode = mode;
    for (index = 0; index < mode; index++) {
        D_800AD138.saved.playerChoices38[index] = index;
        func_80032D28(index, 1, 0);
    }
    D_800AD138.saved.selection34 = 0;
    D_800AD138.saved.currentPlayer = D_800AD138.saved.playerChoices38[D_800AD138.saved.selection34];
    func_800360B8(D_800922DC);
    func_800214D4(1);
    players = D_8009B190;
    players[1].level = D_800B9A78.unknownCCC;
    players[1].valueD70 = D_800B9A78.valueCD0;
    func_800360B8(D_800922FC);
}
