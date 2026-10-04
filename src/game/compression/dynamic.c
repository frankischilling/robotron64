#include "../../../include/compression_internal.h"

int func_8005EEE0(void)
{
    int i;
    unsigned int j;
    unsigned int l;
    unsigned int m;
    unsigned int n;
    InflateCode *tl;
    InflateCode *td;
    unsigned int bl;
    unsigned int bd;
    unsigned int nb;
    unsigned int nl;
    unsigned int nd;
    register unsigned int bitBuffer;
    register unsigned int bitCount;

    bitBuffer = D_80192C08;
    bitCount = D_80192C0C;

    i = bitCount;
    /* This initialized test preserves IDO's saved-register allocation. */
    do {
        while (bitCount < 5) {
            bitBuffer |= (unsigned int)INFLATE_READ_BYTE() << bitCount;
            bitCount += 8;
            if (!i) {
            }
        }
    } while (0);
    nl = 257 + (bitBuffer & 0x1F);
    INFLATE_DROP_BITS(5);
    INFLATE_NEED_BITS(5);
    nd = 1 + (bitBuffer & 0x1F);
    INFLATE_DROP_BITS(5);
    INFLATE_NEED_BITS(4);
    nb = 4 + (bitBuffer & 0xF);
    INFLATE_DROP_BITS(4);

    if (nl > 288 || nd > 32) {
        return 4;
    }

    for (j = 0; j < nb; j++) {
        INFLATE_NEED_BITS(3);
        D_80193628[D_8008DA48[j]] = bitBuffer & 7;
        INFLATE_DROP_BITS(3);
    }
    for (; j < 19; j++) {
        D_80193628[D_8008DA48[j]] = 0;
    }

    bl = 7;
    if ((i = func_8005DA20(D_80193628, 19, 19, 0, 0, &tl, &bl)) != 0) {
        if (i == 2) {
            func_8005E1E4(tl);
        }
        return i;
    }

    n = nl + nd;
    m = D_8008DB8C[bl];
    i = l = 0;
    while ((unsigned int)i < n) {
        INFLATE_NEED_BITS(bl);
        j = (td = tl + (bitBuffer & m))->bits;
        INFLATE_DROP_BITS(j);
        j = td->data.value;

        if (j < 16) {
            l = j;
            D_80193628[i++] = l;
        } else if (j == 16) {
            INFLATE_NEED_BITS(2);
            j = 3 + (bitBuffer & 3);
            INFLATE_DROP_BITS(2);
            if ((unsigned int)i + j > n) {
                return 8;
            }
            while (j--) {
                D_80193628[i++] = l;
            }
        } else if (j == 17) {
            INFLATE_NEED_BITS(3);
            j = 3 + (bitBuffer & 7);
            INFLATE_DROP_BITS(3);
            if ((unsigned int)i + j > n) {
                return 8;
            }
            while (j--) {
                D_80193628[i++] = 0;
            }
            l = 0;
        } else {
            INFLATE_NEED_BITS(7);
            j = 11 + (bitBuffer & 0x7F);
            INFLATE_DROP_BITS(7);
            if ((unsigned int)i + j > n) {
                return 8;
            }
            while (j--) {
                D_80193628[i++] = 0;
            }
            l = 0;
        }
    }

    func_8005E1E4(tl);

    D_80192C08 = bitBuffer;
    D_80192C0C = bitCount;

    bl = 9;
    if ((i = func_8005DA20(D_80193628, nl, 257, D_8008DA94, D_8008DAD4,
                           &tl, &bl)) != 0) {
        if (i == 2) {
            func_8005E1E4(tl);
        }
        return i;
    }

    bd = 6;
    func_8005DA20(D_80193628 + nl, nd, 0, D_8008DB14, D_8008DB50,
                  &td, &bd);
    i = func_8005E1EC(tl, td, bl, bd);
    func_8005E1E4(tl);
    func_8005E1E4(td);
    D_80192BFC = D_80192BF8;
    return i;
}
