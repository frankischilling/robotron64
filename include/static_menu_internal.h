#ifndef ROBOTRON_STATIC_MENU_INTERNAL_H
#define ROBOTRON_STATIC_MENU_INTERNAL_H

#include "menu_label_internal.h"

/* Static pages include the timeout callback read by menu navigation. */
typedef struct MenuStaticPage {
    MenuOptionsPage page;
    void (*timeout30)(void);
} MenuStaticPage;

typedef char MenuStaticPageMustBe52Bytes[
    sizeof(MenuStaticPage) == 0x34 ? 1 : -1];

extern MenuStaticPage D_800772F0[1];
extern MenuStaticPage D_8007751C[1];
extern MenuLabelRecord D_800772A0[2];
extern MenuLabelRecord D_80077454[5];

extern const unsigned char D_8009347C[4];
extern const unsigned char D_80093480[3];
extern const unsigned char D_80093484[7];
extern const unsigned char D_800934F0[23];
extern const unsigned char D_80093508[8];
extern const unsigned char D_80093510[10];
extern const unsigned char D_8009351C[10];
extern const unsigned char D_80093528[9];
extern const unsigned char D_80093534[12];

void func_8002FB54(int *selection);
void func_8002FC9C(int *selection);
void func_8002FC70(int *selection);
void func_8002FC08(int *selection);
void func_80030C3C(int unused);

#endif
