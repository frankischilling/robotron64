#include "../../include/early_game_medium_next.h"
#include "../../include/early_name_table.h"
#include "../../include/game_memory.h"
#include "../../include/text.h"

extern char D_800903AC[];

int func_8001BBAC(unsigned char *name)
{
    int index;

    for (index = 0; index < 14; index++) {
        if (func_8003B768(D_80075994[index], name) == 0) {
            return 1 << index;
        }
    }
    func_8001C0D0(D_800903AC, name, D_80075994[7]);
    return -1;
}
