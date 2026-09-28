#include "../../include/pak_file.h"
#include "../../include/controller_services.h"
#include "../../include/save_game.h"

int func_8004C5DC(void *source, int size, int count, int handle)
{
    unsigned char *buffer;
    int bytes;

    buffer = source;
    bytes = size * count;
    func_80062DEC(&D_8013D9D8[0], D_8013DB78, 1, 0, bytes, buffer);
    D_80075FB8 = 0;
    return bytes;
}
