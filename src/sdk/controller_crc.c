#include "../../include/sdk_si.h"

unsigned char func_8006AA20(unsigned short address)
{
    unsigned char crc;
    unsigned char polynomial;
    int bit;

    crc = 0;
    for (bit = 0; bit < 16; bit++) {
        if (crc & 0x10) {
            polynomial = 0x15;
        } else {
            polynomial = 0;
        }
        crc <<= 1;
        crc |= (unsigned char)((address & 0x400) ? 1 : 0);
        address <<= 1;
        crc ^= polynomial;
    }
    return crc & 0x1F;
}

unsigned char func_8006AAD0(unsigned char *data)
{
    unsigned char crc;
    unsigned char polynomial;
    int index;
    int bit;

    crc = 0;
    for (index = 0; index <= 32; index++, data++) {
        for (bit = 7; bit >= 0; bit--) {
            if (crc & 0x80) {
                polynomial = 0x85;
            } else {
                polynomial = 0;
            }
            crc <<= 1;
            if (index == 32) {
                /* The SDK's final byte shifts in zero bits. */
                crc &= -1;
            } else {
                crc |= ((*data & (1 << bit)) ? 1 : 0);
            }
            crc ^= polynomial;
        }
    }
    return crc;
}
