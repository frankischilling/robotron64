#include "../../include/audio_commands.h"

extern void (*D_8008D880[])(void);
extern volatile int D_8008D8BC;
extern int D_8008D8C0;
extern unsigned char *D_8008D8C4;
extern unsigned char D_80190540[];
extern unsigned char D_80192540[];
extern unsigned char *D_80192740;

void func_800592C0(unsigned char *destination, const unsigned char *source,
                   unsigned int count)
{
    while (count--) {
        *destination++ = *source++;
    }
}

void func_800592F0(int command)
{
    if (D_8008D8C0 == 0) {
        if (D_8008D8BC < 0x200) {
            D_80192540[D_8008D8BC++] = command;
        } else {
            D_8008D8C0 = 1;
        }
    }
}

void func_80059348(const void *source, int count)
{
    if (D_8008D8C0 == 0) {
        if ((D_80190540 - D_8008D8C4) + 0x2000 >= count) {
            func_800592C0(D_8008D8C4, source, count);
            D_8008D8C4 += count;
        } else {
            if (D_8008D8BC > 0) {
                D_8008D8BC--;
            }
            D_8008D8C0 = 1;
        }
    }
}

void func_800593F4(void *destination, int count)
{
    func_800592C0(destination, D_80192740, count);
    D_80192740 += count;
}

void func_80059438(void)
{
    int index;

    D_8008D8C0 = 0;
    D_80192740 = D_80190540;
    for (index = 0; index < D_8008D8BC; index++) {
        D_8008D880[D_80192540[index]]();
    }
    func_8005895C();
    D_8008D8BC = 0;
    D_8008D8C4 = D_80190540;
    func_8005899C();
}
