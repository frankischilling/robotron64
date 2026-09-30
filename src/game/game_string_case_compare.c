#include "../../include/game_memory.h"

int func_8003B768(unsigned char *left, unsigned char *right)
{
    unsigned char value;

    for (;;) {
        value = func_8003BC5C(*left);
        if (value != func_8003BC5C(*right)) {
            value = func_8003BC5C(*left);
            return value - func_8003BC5C(*right);
        }
        if (*left == 0) {
            return 0;
        }
        left++;
        right++;
    }
}
