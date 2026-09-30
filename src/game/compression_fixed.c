#include "../../include/compression_internal.h"

extern unsigned int D_801931A8[288];

int func_8005ECA8(void)
{
    int i;
    int distanceValue;
    int literalValue;

    if (D_8008DA40 == 0) {
        for (i = 0; i < 144; i++) {
            D_801931A8[i] = 8;
        }
        literalValue = 7;
        for (; i < 256; i++) {
            D_801931A8[i] = 9;
        }
        distanceValue = 5;
        for (; i < 280; i++) {
            D_801931A8[i] = literalValue;
        }
        for (; i < 288; i++) {
            D_801931A8[i] = 8;
        }
        D_80192C00 = 7;
        i = func_8005DA20(D_801931A8, 288, 257, D_8008DA94, D_8008DAD4,
                          &D_8008DA40, &D_80192C00);
        if (i) {
            D_8008DA40 = 0;
            return i;
        }
        for (i = 0; i < 30; i++) {
            D_801931A8[i] = distanceValue;
        }
        D_80192C04 = 5;
        i = func_8005DA20(D_801931A8, 30, 0, D_8008DB14, D_8008DB50,
                          &D_8008DA44, &D_80192C04);
        if (i != 0 && i != 2) {
            func_8005E1E4(D_8008DA40);
            D_8008DA40 = 0;
            D_8008DA44 = 0;
            return i;
        }
    }
    return func_8005E1EC(D_8008DA40, D_8008DA44, D_80192C00, D_80192C04);
}
