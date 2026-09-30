#include "../../include/menu_label_internal.h"

void func_80027940(unsigned char **labels, int count)
{
    int i;

    for (i = 0; i < count; i++) {
        unsigned char *label = labels[i];
        D_800AEF00[i].label08 = label;
        D_800AEF00[i].label0C = label;
    }
}
