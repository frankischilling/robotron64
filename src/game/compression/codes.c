#include "../../../include/compression_internal.h"

#define WSIZE 0x8000U

int func_8005E1EC(InflateCode *tl, InflateCode *td,
                  unsigned int bl, unsigned int bd)
{
    register unsigned int e;
    unsigned int n;
    unsigned int d;
    InflateCode *t;
    unsigned int ml;
    unsigned int md;
    unsigned int w;
    register unsigned int bitBuffer;
    register unsigned int bitCount;

    bitBuffer = D_80192C08;
    bitCount = D_80192C0C;
    w = D_80192BF4;
    ml = D_8008DB8C[bl];
    md = D_8008DB8C[bd];

    for (;;) {
        while (bitCount < bl) {
            bitBuffer |= (unsigned int)INFLATE_READ_BYTE() << bitCount;
            bitCount += 8;
        }
        if ((e = (t = tl + (bitBuffer & ml))->operation) > 16) {
            do {
                if (e == 99) {
                    return 7;
                }
                INFLATE_DROP_BITS(t->bits);
                e -= 16;
                INFLATE_NEED_BITS(e);
            } while ((e = (t = t->data.table +
                            (bitBuffer & D_8008DB8C[e]))->operation) > 16);
        }

        INFLATE_DROP_BITS(t->bits);
        if (e == 16) {
            *D_80192BD4++ = (unsigned char)t->data.value;
            if (++w == WSIZE) {
                D_80192BF0 += w;
                w = 0;
            }
            if (--D_80192BEC == 0) {
                break;
            }
        } else {
            if (e == 15) {
                break;
            }

            INFLATE_NEED_BITS(e);
            n = t->data.value + (bitBuffer & D_8008DB8C[e]);
            INFLATE_DROP_BITS(e);

            INFLATE_NEED_BITS(bd);
            if ((e = (t = td + (bitBuffer & md))->operation) > 16) {
                do {
                    if (e == 99) {
                        return 7;
                    }
                    INFLATE_DROP_BITS(t->bits);
                    e -= 16;
                    INFLATE_NEED_BITS(e);
                } while ((e = (t = t->data.table +
                                (bitBuffer & D_8008DB8C[e]))->operation) > 16);
            }

            INFLATE_DROP_BITS(t->bits);
            while (bitCount < e) {
                bitBuffer |= (unsigned int)INFLATE_READ_BYTE() << bitCount;
                bitCount += 8;
            }
            d = w - t->data.value - (bitBuffer & D_8008DB8C[e]);
            INFLATE_DROP_BITS(e);

            do {
                unsigned char *source;

                d &= WSIZE - 1;
                e = WSIZE - (d > w ? d : w);
                if (e > n) {
                    e = n;
                }
                n -= e;

                if (D_80192BEC < e) {
                    e = D_80192BEC;
                    n = 0;
                }
                D_80192BEC -= e;

                if (d >= w) {
                    w += e;
                    source = D_80192BF0 - WSIZE;
                    do {
                        *D_80192BD4++ = source[d++];
                    } while (--e);
                } else {
                    w += e;
                    do {
                        *D_80192BD4++ = D_80192BF0[d++];
                    } while (--e);
                }

                if (w == WSIZE) {
                    D_80192BF0 += w;
                    w = 0;
                }
            } while (n);
        }

    }

    D_80192BF4 = w;
    D_80192C08 = bitBuffer;
    D_80192C0C = bitCount;
    return D_80192BEC == 0 ? 9 : 0;
}
