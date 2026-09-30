#include "../../include/palette_effects.h"
#include "../../include/command_script.h"
#include "../../include/text.h"

extern char D_800940C0[];
extern char D_800940D8[];
extern char D_800940F0[];

void func_8003237C(int *command)
{
    int index = command[1];

    D_800BB230[index].green = command[2];
    D_800BB230[index].red = command[3];
    D_800BB230[index].blue = command[4];
    if (index >= 551) {
        func_8001C0D0(D_800940C0);
    }
}

void func_800323D4(int *command)
{
    int index = command[1];

    if (index >= 31) {
        func_8001C0D0(D_800940D8);
    }
    D_800BEF4C = index;
    D_800BEE58[index].first = D_800BEF48;
    D_800BEE58[index].count = 0;
}

void func_80032434(int *command)
{
    int paletteIndex = command[1];
    int first = command[2];
    int second = command[3];
    int mode = command[4];
    int phase = command[5];
    int step = command[6];

    if (D_800BEF48 >= 550) {
        func_8001C0D0(D_800940F0);
    }
    D_800BBAC8[D_800BEF48].paletteIndex = paletteIndex;
    D_800BBAC8[D_800BEF48].first = first;
    D_800BBAC8[D_800BEF48].second = second;
    D_800BBAC8[D_800BEF48].mode = mode;
    D_800BBAC8[D_800BEF48].phase = phase;
    D_800BBAC8[D_800BEF48].step = step;
    D_800BEE58[D_800BEF4C].count++;
    D_800BEF48++;
}

void func_80032518(int *command)
{
}

void func_80032520(int *command)
{
    D_8009EFB4 = 1;
}
