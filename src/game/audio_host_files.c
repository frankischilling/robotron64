#include "../../include/audio_io.h"

typedef struct AudioFileCursor {
    unsigned int base;
    unsigned int current;
} AudioFileCursor;

extern int D_8008D864;
extern int D_8008D870;
extern AudioFileCursor D_80190320;
extern unsigned int D_80190328;

void func_80058ADC(void)
{
    D_8008D870 = 0;
    D_8008D864 = 1;
}

void func_80058AF4(void)
{
    D_8008D864 = 0;
}

int func_80058B00(int value)
{
    return 1;
}

AudioFileCursor *func_80058B0C(unsigned int address)
{
    D_80190320.base = address;
    D_80190320.current = address;
    return &D_80190320;
}

unsigned int func_80058B20(void *destination, unsigned int count, AudioFileCursor *file)
{
    func_80051924(file->current, destination, count);
    file->current += count;
    return count;
}

int func_80058B74(AudioFileCursor *file, unsigned int offset, int origin)
{
    if (origin == 0) {
        file->current = file->base + offset;
    } else if (origin == 1) {
        file->current += offset;
    }
    return 0;
}

unsigned int func_80058BB0(AudioFileCursor *file)
{
    return file->current;
}

void func_80058BBC(AudioFileCursor *file)
{
}

int func_80058BC4(int value)
{
    return 1;
}

void *func_80058BD0(int value)
{
    return &D_80190328;
}

int func_80058BE0(int first, int second, int third, int fourth)
{
    return 0;
}

void func_80058BF8(void *file)
{
}
