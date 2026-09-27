#include "../../include/text.h"
int func_800011AC(int *slot, unsigned char *text, int scale, int mode, int replace, int options)
{
    if (*slot == -1) {
        *slot = func_80000918(text, scale, mode, options);
        if (options) {
            func_80000B7C(*slot, options, 0);
        }
        return 1;
    }
    if (replace && func_8003B7FC(text, D_800B6FF8[*slot].text)) {
        func_80000F48(*slot, text);
    }
    return 0;
}
