#include "../../../include/menu_label_internal.h"

extern unsigned char D_80093800[];
extern unsigned char D_80093820[];
void func_8001C0D0(unsigned char *format, ...);
void func_80026178(void *menu, int mode);

void func_800263E0(unsigned char *title, unsigned char **labels, int count,
                   int mode, int first, int second,
                   void (*select)(int *), void (*cancel)(int), int width)
{
    unsigned int maximum = 0;
    int i;
    int next;
    int limit;

    if (count > MENU_OPTION_LIMIT) {
        count = MENU_OPTION_LIMIT;
        func_8001C0D0(D_80093800, count);
    }
    limit = count + 1;
    i = 0;
    if (limit > 0) {
        do {
            next = i + 1;
            if (count == next) {
                D_800AEF00[i].spacing1C = 30;
            } else {
                D_800AEF00[i].spacing1C = 20;
            }
            D_800AEF00[i].value20 = 0;
            D_800AEF00[i].textSlot10 = -1;
            D_800AEF00[i].sound24 = 68;
            D_800AEF00[i].selection14 = &D_800AF1A8.selection14;
            if (i == count) {
                D_800AEF00[i].label08 = D_80093820;
                D_800AEF00[i].label0C = D_80093820;
                D_800AEF00[i].flags00 = 0x28900;
                D_800AEF00[i].next18 = 0;
                D_800AEF00[i].callback04.cancel = cancel;
            } else {
                unsigned char *label = labels[i];

                D_800AEF00[i].flags00 = 0x100;
                D_800AEF00[i].next18 = &D_800AEF00[i + 1];
                D_800AEF00[i].callback04.select = select;
                D_800AEF00[i].label08 = label;
                D_800AEF00[i].label0C = label;
            }
            if (maximum < func_8003B4FC(D_800AEF00[i].label0C)) {
                maximum = func_8003B4FC(D_800AEF00[i].label0C);
            }
            i++;
        } while (i != limit);
    }
    D_800AF1A8.title00 = title;
    D_800AF1A8.textSlot04 = -1;
    D_800AF1A8.value18 = 100;
    D_800AF1A8.value1C = 200;
    D_800AF1A8.width0C = width;
    D_800AF1A8.value08 = 0;
    D_800AF1A8.value10 = 90;
    D_800AF1A8.child20 = D_800AEF00;
    D_800AF1A8.sound24 = 34;
    D_800AF1A8.mode28 = mode;
    D_800AF1A8.preview2C = first;
    func_80026178(&D_800AF1A8, 1);
}
