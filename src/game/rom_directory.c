#include "../../include/rom_files.h"
#include "../../include/heap.h"
#include "../../include/pi.h"

extern unsigned char D_00097E90[];
extern unsigned char D_00097E94[];
extern int D_8008D4D0;

unsigned int func_8004EB80(unsigned int *word)
{
    unsigned int original = *word;
    unsigned int result;

    result = (((original >> 16) & 0xFF) << 8) |
             ((original >> 24) & 0xFF) |
             (((original >> 8) & 0xFF) << 16) | ((original & 0xFF) << 24);
    *word = result;
    return result;
}

int func_8004EBC0(short *word)
{
    unsigned int original = *word;
    unsigned int result;

    result = ((original & 0xFF) << 8) | ((original >> 8) & 0xFF);
    *word = result;
    return result;
}

void func_8004EBE4(void)
{
    int count;
    int i;

    if (D_8008D4D0 == 0) {
        func_80063560((unsigned int)D_00097E90, (unsigned int *)&count);
        func_8004EB80((unsigned int *)&count);
        D_80141200 = func_8004DD6C(count * sizeof(RomFileEntry));
        func_8004EE30(D_80141200, (unsigned int)D_00097E94,
                     count * sizeof(RomFileEntry));
        for (i = 0; i < count; i++) {
            func_8004EB80(&D_80141200[i].deviceAddress);
            func_8004EB80((unsigned int *)&D_80141200[i].size);
            D_80141200[i].deviceAddress += (int)D_00097E90;
        }
        D_80141204 = count;
        D_8008D4D0 = 1;
    }
}

void func_8004ED0C(void)
{
}
