#include "../../include/audio_sequence_internal.h"

int func_8005D8AC(int first, int count, unsigned char *destination)
{
    int bytes;
    int index;

    bytes = 0;
    if (D_80192BC0) {
        if (!func_8005CD48()) {
            return 0;
        }
        index = first;
        if (count == 0) {
            return 0;
        }
        while (count--) {
            bytes += func_8005D584(index, destination + bytes);
            ++index;
        }
        func_8005CDB8();
    }
    return bytes;
}
