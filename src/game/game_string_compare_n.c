#include "../../include/game_memory.h"

int func_8003B8E0(unsigned char *left, unsigned char *right, int count)
{
    unsigned char value;
    while (count > 0) {
        value = *left++;
        if (value != *right) {
            return value - *right;
        }
        count--;
        if (!value) {
            return 0;
        }
        right++;
    }
    return 0;
}
