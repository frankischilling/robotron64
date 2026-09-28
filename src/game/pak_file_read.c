#include "../../include/pak_file.h"
#include "../../include/controller_services.h"
#include "../../include/game_memory.h"
#include "../../include/save_game.h"

int func_8004C564(void *destination, int size, int count, int handle)
{
    unsigned char *buffer;
    int bytes;

    buffer = destination;
    bytes = size * count;
    func_8003B694(buffer, 0, bytes);
    func_80062DEC(&D_8013D9D8[0], D_8013DB78, 0, 0, bytes, buffer);
    D_80075FB8 = 0;
    return bytes;
}
