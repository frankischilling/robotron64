#include "../../include/text.h"
int func_80001270(int slot, int offset, unsigned char *text)
{
    TextRecord *record;
    unsigned char buffer[60];
    if (slot >= 0) {
        record = &D_800B6FF8[slot];
        if (func_8003B4FC(text) + offset != record->length || func_8003B7FC(text, record->text + offset)) {
            func_8003B694(buffer, ' ', 60);
            func_8003B520(buffer, record->text, func_8003B4FC(record->text));
            func_8003B6E4(buffer + offset, text);
            func_80000F48(slot, buffer);
            return 1;
        }
    }
    return 0;
}
void func_80001360(void)
{
    int index;
    int slot;
    for (index = 0; index < 30; index++) {
        if (D_800B6FF8[index].active) {
            slot = index;
            func_80000ACC(&slot);
        }
    }
}
