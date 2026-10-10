#include "../../../include/heap.h"

/* Excluded candidate; see docs/projectile-trail-and-arena.md. */
void func_8004DE8C(void *start, void *end)
{
    register unsigned int address;
    register unsigned int size;
    register unsigned int header;
    register unsigned int *block;
    unsigned int *terminator;

    address = ((unsigned int)start + 3) & ~3;
    D_8013EBF0 = (int *)address;
    block = (unsigned int *)D_8013EBF0;
    end = (void *)((unsigned int)end & ~3);
    size = ((unsigned int)end - address - 8) & ~3;
    header = size | 1;
    D_8013EBF0[0] = header;
    terminator = block + ((header >> 2) + 1);
    *terminator = -2;
}
