#include "../../../include/heap.h"

/* Excluded candidate; see docs/projectile-trail-and-arena.md. */
void func_8004DE8C(void *start, void *end)
{
    unsigned int size;
    unsigned int header;
    unsigned int *block;
    unsigned int *terminator;

    block = (unsigned int *)(((unsigned int)start + 3) & ~3);
    end = (void *)((unsigned int)end & ~3);
    size = ((unsigned int)end - (unsigned int)block - 8) & ~3;
    header = size | 1;
    D_8013EBF0 = (int *)block;
    *block = header;
    terminator = block + (header >> 2) + 1;
    *terminator = -2;
}
