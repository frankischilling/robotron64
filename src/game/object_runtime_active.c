#include "../../include/object_runtime.h"
#include "../../include/debug_output.h"

extern unsigned char D_800C85C0[];
extern char D_80094C10[];

void func_8003B428(int *indices)
{
    int i;
    int index;
    int *list;

    list = indices;

    for (i = 0; i < 256; i++) {
        D_800C85C0[i] = 0;
    }

    for (;;) {
        index = *list;
        list++;
        if (index == 0) {
            break;
        }
        D_800C85C0[index] = 1;
        func_80048DC0(D_80094C10, index);
    }
}
