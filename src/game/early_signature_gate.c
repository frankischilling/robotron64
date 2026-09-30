#include "../../include/save_game.h"
#include "../../include/game_memory.h"

const unsigned char D_8008F930[] = "laddie";
const unsigned char D_8008F938[] = "arvid";
extern int D_8007D8FC;
void func_8001B8D8(int *command, int unused);

int func_80005DEC(void)
{
    int command = 3;

    if (func_8003B7FC(D_800AD318.data.signature, D_8008F930) != 0) {
        return 0;
    }
    if (D_800AD318.words[5] != 1234567) {
        return 0;
    }
    if (func_8003B7FC(&D_800AD318.data.configuration[4], D_8008F938) != 0) {
        return 0;
    }
    D_8007D8FC = 1;
    func_8001B8D8(&command, 0);
}
