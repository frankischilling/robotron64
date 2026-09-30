#include "../../include/audio_sequence_internal.h"

int func_8005D830(int first, int count)
{
    int bytes;
    int index;

    bytes = 0;
    if (D_80192BC0) {
        index = first;
        if (count == 0) {
            return 0;
        }
        while (count--) {
            bytes += func_8005D4C8(index);
            ++index;
        }
    }
    return bytes;
}
