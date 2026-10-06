#include "../../../include/early_input_internal.h"

extern EarlyInputSequence D_8009EE24, D_8009EF74, D_8009EF58;
void func_8001C0D0(unsigned char *format, ...);

void func_8001BE2C(int *command)
{
    int length;
    int current;
    int index;
    int field08;
    int field04;
    int field0C;
    int field10;
    EarlyInputSequence *sequence;

    current = D_8009E588;
    length = command[7];
    index = command[1];
    field08 = command[2];
    field04 = command[4];
    field0C = command[5];
    field10 = command[6];
    sequence = index + D_8009EE08;
    sequence->buttons = D_8009E590 + current;
    sequence->length = length;
    sequence->unknown04 = field04;
    sequence->unknown08 = field08;
    sequence->unknown0C = field0C;
    sequence->unknown10 = field10;
    if (length + current >= 400) {
        func_8001C0D0((unsigned char *)D_800903C8, current, sequence->length, 400); current = D_8009E588;
    }
    D_8009E588 = (int)(current + (unsigned int)sequence->length);
    if (sequence == &D_8009EE24) {
        sequence->length = 24;
        sequence->buttons = D_80073A48;
    }
    if (sequence == &D_8009EF74) {
        sequence->length = 3;
        sequence->buttons = D_80073A78;
    }
    if (sequence == &D_8009EF58) {
        sequence->length = 4;
        sequence->buttons = D_80073A80;
    }
}
