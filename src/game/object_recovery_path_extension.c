#include "../../include/object_recovery.h"
#include "../../include/game_memory.h"

unsigned char *func_8003CBEC(unsigned char *destination, unsigned char *source)
{
    unsigned char *extension;

    extension = func_8003B4C0(destination, '.');
    if (extension != 0) {
        *extension = 0;
    }
    return func_8003B734(destination, source);
}
