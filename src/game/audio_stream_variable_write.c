#include "../../include/audio_property_pipeline_internal.h"

unsigned char *func_800595D4(unsigned char *data, unsigned int value)
{
    unsigned char encoded[10];
    unsigned char *cursor;

    encoded[0] = value & 127;
    cursor = encoded + 1;
    while (value >>= 7) {
        *cursor++ = (value & 127) | 128;
    }
    for (--cursor; ; --cursor) {
        *data++ = *cursor;
        if (!(*cursor & 128)) {
            break;
        }
    }
    return data;
}
