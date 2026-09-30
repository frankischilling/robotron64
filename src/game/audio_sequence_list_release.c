#include "../../include/audio_sequence_internal.h"

int func_8005D7B4(short *indices)
{
    short *cursor;
    int released;
    int index;

    released = 0;
    if (D_80192BC0 && *indices != -1) {
        cursor = indices;
        do {
            index = *cursor;
            released = 1;
            func_8005D610(index);
            ++cursor;
        } while (*cursor != -1);
    }
    return released;
}
