#include "../../include/early_game_medium.h"
#include "../../include/early_name_table.h"

#define EARLY_VALUE_COLUMN_0 (D_80075994)
#define EARLY_VALUE_COLUMN_1 (D_80075994 + 1)
#define EARLY_VALUE_COLUMN_2 (D_80075994 + 2)
#define EARLY_VALUE_COLUMN_3 (D_80075994 + 3)

unsigned char *func_8001BC38(int mask)
{
    int shift;

    if (mask == 1) {
        return EARLY_VALUE_COLUMN_0[0];
    }
    shift = 2;
    if (mask == 2) {
        return EARLY_VALUE_COLUMN_1[0];
    }
loop:
    if (mask == (1 << shift)) {
        return EARLY_VALUE_COLUMN_0[shift];
    }
    if (mask == (1 << (shift + 1))) {
        return EARLY_VALUE_COLUMN_1[shift];
    }
    if (mask == (1 << (shift + 2))) {
        return EARLY_VALUE_COLUMN_2[shift];
    }
    if (mask == (1 << (shift + 3))) {
        return EARLY_VALUE_COLUMN_3[shift];
    }
    shift += 4;
    if (shift != 14) {
        goto loop;
    }
    return 0;
}
