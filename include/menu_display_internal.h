#ifndef ROBOTRON_MENU_DISPLAY_INTERNAL_H
#define ROBOTRON_MENU_DISPLAY_INTERNAL_H

#include "save_menu_nav_internal.h"

typedef struct MenuDisplayChoice {
    unsigned char *text;
    int value04;
} MenuDisplayChoice;

typedef char MenuDisplayChoiceMustBe8Bytes[
    sizeof(MenuDisplayChoice) == 8 ? 1 : -1];
typedef char MenuDisplayLongMustBe4Bytes[sizeof(long) == 4 ? 1 : -1];

extern MenuDisplayChoice D_800761F8[2];
extern unsigned char D_80092C08[4];
extern unsigned char D_80092C0C[4];
extern unsigned char D_800938C8[8];
extern int D_8009EF94;

void func_8000177C(int slot, int x, int z, int y, int pitch, int yaw,
                   int roll, int scale, int first, int second, int third,
                   int enabled, int state, int limit, int value);
void func_8002741C(void);

#endif
