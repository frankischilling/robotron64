#include "../../include/early_game_medium_next.h"
#include "../../include/game_memory.h"

int func_8001BD24(short *output, unsigned char *input)
{
    int count;
    int length;
    unsigned char token[100];

    count = 0;
    do {
        int value;

        length = 0;
        while (func_8003BBDC(*input) != 0 || *input == '_') {
            token[length++] = *input++;
        }
        token[length] = 0;
        value = func_8001BBAC(token);
        *output = (short)value;
        if ((short)value == -1) {
            return -1;
        }
        output++;
        count++;
    } while (*input++ == '|');

    return count;
}
