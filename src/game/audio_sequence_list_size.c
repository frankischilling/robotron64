#include "../../include/audio_sequence_internal.h"

int func_8005D690(short *indices)
{
    int bytes;
    short *cursor;
    int index;

    bytes = 0;
    if (D_80192BC0 && *indices != -1) {
        cursor = indices;
        do {
            index = *cursor;
            bytes += func_8005D4C8(index);
            ++cursor;
        } while (*cursor != -1);
    }
    return bytes;
}
