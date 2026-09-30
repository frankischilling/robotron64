#include "../../include/game_memory.h"

int func_8003B7FC(const unsigned char *left, const unsigned char *right)
{
    unsigned char value;
    for (;;) {
        value = *left++;
        if (value != *right) {
            return value - *right;
        }
        if (!value) {
            return 0;
        }
        right++;
    }
}
