#include "../../include/audio_property_pipeline_internal.h"

unsigned char *func_80059580(unsigned char *data, unsigned int *delay)
{
    unsigned int value;
    unsigned char byte;

    value = *data++;
    if (value & 128) {
        value &= 127;
        do {
            byte = *data;
            value = (byte & 127) + (value << 7);
            data++;
        } while (byte & 128);
        D_80192754 = byte;
    }
    *delay = value;
    D_80192750 = value;
    return data;
}
