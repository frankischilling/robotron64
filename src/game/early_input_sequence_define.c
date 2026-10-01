#include "../../include/early_input_internal.h"

extern unsigned char D_800903C8[];
void func_8001C0D0(unsigned char *format, ...);

void func_8001BE2C(int *command)
{
    int index;
    int field08;
    int field04;
    int field0C;
    int field10;
    int length;
    EarlyInputSequence *sequence;

    index = command[1];
    field08 = command[2];
    field04 = command[4];
    field0C = command[5];
    field10 = command[6];
    length = command[7];
    sequence = &D_8009EE08[index];
    sequence->length = length;
    sequence->buttons = D_8009E590 + D_8009E588;
    sequence->unknown04 = field04;
    sequence->unknown08 = field08;
    sequence->unknown0C = field0C;
    sequence->unknown10 = field10;
    if (length + D_8009E588 >= 400) {
        func_8001C0D0(D_800903C8, D_8009E588, length, 400);
    }
    D_8009E588 += sequence->length;
    if (sequence == &D_8009EE08[1]) {
        sequence->length = 24;
        sequence->buttons = D_80073A48;
    }
    if (sequence == &D_8009EE08[13]) {
        sequence->length = 3;
        sequence->buttons = D_80073A78;
    }
    if (sequence == &D_8009EE08[12]) {
        sequence->length = 4;
        sequence->buttons = D_80073A80;
    }
}
