#ifndef ROBOTRON_MENU_LABEL_INTERNAL_H
#define ROBOTRON_MENU_LABEL_INTERNAL_H

#include "save_game.h"

typedef struct MenuLabelRecord {
    unsigned char unknown00[8];
    unsigned char *label08;
    unsigned char *label0C;
    unsigned char unknown10[0x18];
} MenuLabelRecord;

typedef char MenuLabelRecordMustBe40Bytes[
    sizeof(MenuLabelRecord) == 0x28 ? 1 : -1];

extern MenuLabelRecord D_800AEF00[];

#endif
