#include "../../include/game_memory.h"

char D_80090370[] = "Get from a simple list failed for %s\n";
void func_8001C0D0(char *format, ...);

int func_8001B7D0(unsigned char *name, unsigned char **table,
                   unsigned char **fallback)
{
    int i;

    while (table != 0) {
        for (i = 0; table[i] != 0; i++) {
            if (func_8003B768(name, table[i]) == 0) {
                return i;
            }
        }
        table = fallback;
        fallback = 0;
    }
    func_8001C0D0(D_80090370, name);
    return -1;
}
