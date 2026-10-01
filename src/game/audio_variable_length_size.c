#include "../../include/audio_property_pipeline_internal.h"

unsigned char func_80059644(unsigned int value)
{
    unsigned char *input;
    unsigned char reverse[8];
    unsigned char forward[16];
    unsigned char *output;

    output = forward;
    input = reverse;
    *input++ = value & 0x7f;
    value >>= 7;
    while (value != 0) {
        *input = (value & 0x7f) | 0x80, value >>= 7;
        input++;
    }
    input--;
    for (;;) {
        *output++ = *input;
        if ((*input & 0x80) == 0) {
            break;
        }
        input--;
    }
    return output - forward;
}
