#include "../../include/heap.h"

extern int D_8008D480;
extern int *D_8013EBF0;

void func_8004DE8C(void *start, void *end);

void func_8004DC70(void *ptr)
{
    if (ptr != 0) {
        ((int *)ptr)[-1] |= 1;
    }
}

int func_8004DC90(void)
{
    int *block;
    int size;
    int total;

    block = D_8013EBF0;
    total = 0;
    size = *block;
    while (size > 0) {
        if ((size & 1) == 1) {
            total += size - 1;
        }
        block += (size >> 2) + 1;
        size = *block;
    }
    return total;
}

int func_8004DCE0(void)
{
    int *block;
    int *previous;
    int size;
    int largest;

    previous = 0;
    largest = 0;
    block = D_8013EBF0;
    size = *block;
    while (size > 0) {
        if ((size & 1) == 1) {
            if (previous != 0) {
                block = previous;
                size = (*previous += size + 3);
            } else {
                previous = block;
            }
            if (largest < size) {
                largest = size - 1;
            }
        } else {
            previous = 0;
        }
        block += (size >> 2) + 1;
        size = *block;
    }
    return largest;
}

void *func_8004DD6C(int size)
{
    int *block;
    int *previous;
    int block_size;
    unsigned int remainder;

    previous = 0;
    if (D_8008D480 == 0) {
        D_8008D480 = 1;
        func_8004DE8C((void *)0x80225800, (void *)0x803CDFFC);
    }

    size = (size + 3) & ~3;
    block = D_8013EBF0;
    while (1) {
        block_size = *block;
        if (block_size <= 0) {
            return 0;
        }
        if ((block_size & 1) == 1) {
            if (previous != 0) {
                block = previous;
                block_size = (*previous += block_size + 3);
            } else {
                previous = block;
            }
            if (size + 1 == block_size) {
                *block -= 1;
                return block + 1;
            }
            if (size + 1 < block_size) {
                remainder = block_size - size - 4;
                *block = remainder;
                block += (remainder >> 2) + 1;
                *block = size;
                return block + 1;
            }
        } else {
            previous = 0;
        }
        block += (block_size >> 2) + 1;
    }
}
