#include "../../include/game_memory.h"

int func_8003B838(unsigned char *left, unsigned char *right, int count)
{
    unsigned int rawCharacter;
    unsigned char value;
    unsigned char rightValue;
    unsigned char character;

    if (count > 0) {
        for (;;) {
            value = func_8003BC5C(*left);
            rightValue = func_8003BC5C(*right);
            count--;
            if (rightValue != value) {
                value = func_8003BC5C(*left);
                return value - func_8003BC5C(*right);
            }
            rawCharacter = *left++;
            character = rawCharacter;
            if (character == 0) {
                return 0;
            }
            right++;
            if (count <= 0) {
                break;
            }
        }
    }
    return 0;
}
