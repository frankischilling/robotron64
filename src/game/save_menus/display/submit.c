#include "../../../../include/menu_display_internal.h"

void func_8002741C(void)
{
    int x;
    long y;
    int index;
    int value;
    int drawMode;
    MenuOptionsPage *page;
    MenuLabelRecord *label;
    unsigned char number[100];

    page = (MenuOptionsPage *)D_800AEE98.menu04;
    if (page != 0) {
        x = page->value08;
        y = page->width0C;
        func_80000518(page->title00);
        page = (MenuOptionsPage *)D_800AEE98.menu04;
        func_800011AC(&page->textSlot04, page->title00, 1500, 11, 0, 0);
        value = D_800761F4 ? 60 : 0;
        func_8000177C(((MenuOptionsPage *)D_800AEE98.menu04)->textSlot04,
                       D_800AEE98.drawX44 + x,
                       D_800AEE98.previewY48 - 40000,
                       (y - value) * 130 + D_800AEE98.drawY4C - 45500,
                       2278, 0, 0, 2500, 0, 0, 0, 1, 1, 20, 180);
        label = ((MenuOptionsPage *)D_800AEE98.menu04)->child20;
        while (label != 0) {
            if (label == (MenuLabelRecord *)D_800AEE98.selected50 &&
                label->label0C != 0 && !(label->flags00 & 0x1000)) {
                func_80000518(label->label0C);
                func_800011AC(&label->textSlot10, label->label0C, 1000, 11, 1, 0);
            } else {
                func_80000518(label->label08);
                func_800011AC(&label->textSlot10, label->label08, 1000, 11, 1, 0);
            }
            if (label == (MenuLabelRecord *)D_800AEE98.selected50 && D_8009EF94 != 0) {
                if ((unsigned int)((func_8004CDE8() >> 3) % 20000) /
                    (unsigned int)D_8009EF94 == 0 &&
                    (func_80000E74(label->textSlot10) & 2) &&
                    !(func_80000E74(label->textSlot10) & 0x10)) {
                    func_80000B7C(label->textSlot10, 0x10, 0);
                }
            }
            value = label->flags00;
            if (value & 0x200) {
                func_80001270(label->textSlot10,
                               func_8003B4FC(label->label08) + 1,
                               D_800761F8[*label->selection14 & 1].text);
            }
            if ((label->flags00 & 0x400) && !(label->flags00 & 0x10000)) {
                if (!(label->flags00 & 0x1000)) {
                    if (*label->selection14 == 105000) {
                        func_8003B6E4(number, D_800938C8);
                    } else {
                        func_8003B928(*label->selection14 + 1, number, 10);
                        for (index = 0; index < func_8003B4FC(number); index++) {
                            number[index] += 122;
                        }
                    }
                    func_80001270(label->textSlot10,
                                   func_8003B4FC(label->label08) + 1, number);
                } else {
                    func_80001270(label->textSlot10,
                                   func_8003B4FC(label->label08) + 1,
                                   func_80000518(func_8003BCC4(
                                       ((MenuDisplayChoice *)label->label0C)[*label->selection14].text)));
                }
            }
            drawMode = (func_80000E74(label->textSlot10) & 2) ? 1 : 24;
            func_8000177C(label->textSlot10,
                           D_800AEE98.drawX44 + x,
                           D_800AEE98.previewY48 - 40000,
                           D_800AEE98.drawY4C + y * 130 - 39000,
                           2278, 0, 0, 2500, 0, 0, 0, 1, 1, 32767, drawMode);
            y += label->spacing1C;
            label = label->next18;
        }
    }
}
