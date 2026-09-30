#include "../../include/audio_sequence_internal.h"

int func_8005D708(short *indices, unsigned char *destination)
{
    int bytes;
    short *cursor;
    int index;

    bytes = 0;
    if (D_80192BC0) {
        if (!func_8005CD48()) {
            return 0;
        }
        if (*indices != -1) {
            cursor = indices;
            do {
                index = *cursor;
                bytes += func_8005D584(index, destination + bytes);
                ++cursor;
            } while (*cursor != -1);
        }
        func_8005CDB8();
    }
    return bytes;
}
