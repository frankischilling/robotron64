#include "../../include/compression_internal.h"

InflateCode *D_8008DA40 = 0;

InflateCode *D_8008DA44 = 0;

/* Canonical DEFLATE code-length order. */
unsigned int D_8008DA48[19] = {
    16, 17, 18, 0, 8, 7, 9, 6,
    10, 5, 11, 4, 12, 3, 13, 2,
    14, 1, 15
};

/* Literal/length and distance bases, extra bits, and masks. */
unsigned short D_8008DA94[32] = {
    3, 4, 5, 6, 7, 8, 9, 10,
    11, 13, 15, 17, 19, 23, 27, 31,
    35, 43, 51, 59, 67, 83, 99, 115,
    131, 163, 195, 227, 258, 0, 0, 0
};

unsigned short D_8008DAD4[32] = {
    0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 2, 2, 2, 2,
    3, 3, 3, 3, 4, 4, 4, 4,
    5, 5, 5, 5, 0, 99, 99, 0
};

unsigned short D_8008DB14[30] = {
    1, 2, 3, 4, 5, 7, 9, 13,
    17, 25, 33, 49, 65, 97, 129, 193,
    257, 385, 513, 769, 1025, 1537, 2049, 3073,
    4097, 6145, 8193, 12289, 16385, 24577
};

unsigned short D_8008DB50[30] = {
    0, 0, 0, 0, 1, 1, 2, 2,
    3, 3, 4, 4, 5, 5, 6, 6,
    7, 7, 8, 8, 9, 9, 10, 10,
    11, 11, 12, 12, 13, 13
};

unsigned short D_8008DB8C[17] = {
    0, 1, 3, 7, 15, 31, 63, 127,
    255, 511, 1023, 2047, 4095, 8191, 16383, 32767,
    65535
};

/* Shared input, output, refill, and window state. */
unsigned char *D_80192BD0;
unsigned char *D_80192BD4;
unsigned int D_80192BD8;
unsigned char *D_80192BDC;
int D_80192BE0;
int D_80192BE4;
int D_80192BE8;
unsigned int D_80192BEC;
unsigned char *D_80192BF0;
unsigned int D_80192BF4;
unsigned char *D_80192BF8;
unsigned char *D_80192BFC;
unsigned int D_80192C00;
unsigned int D_80192C04;
unsigned int D_80192C08;
unsigned int D_80192C0C;


/* Code counts, table levels, sorted symbols, and length workspaces. */
unsigned int D_80192C10[17];
unsigned int D_80192C58[17];
InflateCode *D_80192CA0[16];
unsigned int D_80192CE0[288];
unsigned int D_80193160[17];
unsigned int D_801931A8[288];
unsigned int D_80193628[320];

int func_8005F71C(void *scratch, unsigned int size, int memoryInput)
{
    if (scratch == 0 || size < (memoryInput ? 0 : 0x10000) + 0x5DC0U) {
        return 1;
    }
    D_80192BF0 = D_80192BD4;
    if (memoryInput) {
        D_80192BF8 = (unsigned char *)(((unsigned int)scratch + 7) & ~7U);
        D_80192BFC = D_80192BF8;
    } else {
        D_80192BDC = (unsigned char *)(((unsigned int)scratch + 7) & ~7U);
        D_80192BE0 = 0;
        D_80192BE8 = 1;
        D_80192BF8 = (unsigned char *)(((unsigned int)D_80192BDC + 0x10000 + 7) & ~7U);
        D_80192BFC = D_80192BF8;
    }
    return 0;
}
