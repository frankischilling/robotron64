#include "../../../include/compression_internal.h"

#define BMAX 16

int func_8005DA20(unsigned int *b, unsigned int n, unsigned int s,
                  unsigned short *d, unsigned short *e,
                  InflateCode **t, unsigned int *m)
{
    unsigned int a;
    unsigned int el;
    unsigned int f;
    int g;
    int h;
    register unsigned int i;
    register unsigned int j;
    register int k;
    int *l = (int *)&D_80192C58[1];
    register unsigned int *p;
    register InflateCode *q;
    InflateCode r;
    register int w;
    unsigned int *xp;
    int y;
    unsigned int z;

    el = n > 256 ? b[256] : BMAX;

    for (i = 0; i < BMAX + 1; i++) {
        D_80192C10[i] = 0;
    }

    p = b;
    i = n;
    do {
        D_80192C10[*p]++;
        p++;
    } while (--i);

    if (D_80192C10[0] == n) {
        *t = 0;
        *m = 0;
        return 0;
    }

    for (j = 1; j <= BMAX; j++) {
        if (D_80192C10[j]) {
            break;
        }
    }
    k = j;
    if (*m < j) {
        *m = j;
    }

    for (i = BMAX; i; i--) {
        if (D_80192C10[i]) {
            break;
        }
    }
    g = i;
    if (*m > i) {
        *m = i;
    }

    for (y = 1 << j; j < i; j++, y <<= 1) {
        if ((y -= D_80192C10[j]) < 0) {
            return 6;
        }
    }
    if ((y -= D_80192C10[i]) < 0) {
        return 6;
    }
    D_80192C10[i] += y;

    j = 0;
    D_80193160[1] = j;
    p = D_80192C10 + 1;
    xp = D_80193160 + 2;
    while (--i) {
        j += *p++;
        *xp++ = j;
    }

    p = b;
    i = 0;
    do {
        if ((j = *p++) != 0) {
            D_80192CE0[D_80193160[j]++] = i;
        }
    } while (++i < n);

    D_80193160[0] = i = 0;
    p = D_80192CE0;
    h = -1;
    D_80192C58[0] = 0;
    w = 0;
    D_80192CA0[0] = 0;
    q = 0;
    z = 0;

    for (; k <= g; k++) {
        a = D_80192C10[k];
        while (a--) {
            while (k > w + l[h]) {
                w += l[h++];

                z = (z = g - w) > *m ? *m : z;
                if ((f = 1 << (j = k - w)) > a + 1) {
                    f -= a + 1;
                    xp = D_80192C10 + k;
                    while (++j < z) {
                        if (*++xp >= (f <<= 1)) {
                            break;
                        }
                        f -= *xp;
                    }
                }

                if ((unsigned int)w + j > el && (unsigned int)w < el) {
                    j = el - w;
                }
                z = 1 << j;
                l[h] = j;

                q = (InflateCode *)func_8005F7E0((z + 1) * sizeof(InflateCode));
                if (q == 0) {
                    if (h) {
                        func_8005E1E4(D_80192CA0[0]);
                    }
                    return 1;
                }

                *t = q + 1;
                *(t = &q->data.table) = 0;
                D_80192CA0[h] = ++q;

                if (h) {
                    D_80193160[h] = i;
                    r.bits = (unsigned char)l[h - 1];
                    r.operation = (unsigned char)(16 + j);
                    r.data.table = q;
                    j = (i & ((1 << w) - 1)) >> (w - l[h - 1]);
                    D_80192CA0[h - 1][j] = r;
                }
            }

            r.bits = (unsigned char)(k - w);
            if (p >= D_80192CE0 + n) {
                r.operation = 99;
            } else if (*p < s) {
                r.operation = (unsigned char)(*p < 256 ? 16 : 15);
                r.data.value = (unsigned short)*p++;
            } else {
                r.operation = (unsigned char)e[*p - s];
                r.data.value = d[*p++ - s];
            }

            f = 1 << (k - w);
            for (j = i >> w; j < z; j += f) {
                q[j] = r;
            }

            for (j = 1 << (k - 1); i & j; j >>= 1) {
                i ^= j;
            }
            i ^= j;

            while ((i & ((1 << w) - 1)) != D_80193160[h]) {
                w -= l[--h];
            }
        }
    }

    *m = l[0];
    return y != 0 && g != 1 ? 2 : 0;
}
