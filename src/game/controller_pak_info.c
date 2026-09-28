#include "../../include/controller_services.h"

int func_8004F990(void)
{
    int freeBytes;

    if (func_80064140(&D_8013D9D8[0], &freeBytes) != 0) {
        return -1;
    }
    return freeBytes >> 8;
}

int func_8004F9D4(void)
{
    int used;
    int capacity;

    if (func_80064290(&D_8013D9D8[0], &capacity, &used) != 0) {
        return 0;
    }
    return used;
}
