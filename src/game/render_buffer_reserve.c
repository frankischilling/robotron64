#include "../../include/debug_output.h"
#include "../../include/resource_arena.h"

static const unsigned char D_800954F0[] = "CHUNK MEMORY EXCEEDED ptr=%x end=%x len=%d %s %d\n";
static const unsigned char D_80095524[] = "resource.c";

void *func_8004BBD0(unsigned int size)
{
    D_8013D9C0 += size;
    if (D_8013D9C0 > D_8013D9C8) {
        func_800496E0(D_800954F0, D_8013D9C0, D_8013D9C8,
                      size, D_80095524, 94);
    }
    return D_8013D9C0 - size;
}
