#include "../../include/actor_setup_internal.h"

extern int D_80075DB0;
extern int D_80075F40;
extern int D_80074BB4;
extern int D_80074BB8;

void func_8001F1D8(void)
{
    int *slot;
    int *end;

    slot = &D_80075DB0, end = &D_80075F40;
    do {
        func_80000ACC(slot);
        slot += 5;
    } while (slot != end);
    func_80000ACC(&D_80074BB4);
    func_80000ACC(&D_80074BB8);
}
