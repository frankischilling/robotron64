#include "../../include/graphics_state_internal.h"

static const unsigned char D_80095220[] = "DL stack overrun %x %s %d \n";
static const unsigned char D_8009523C[] = "mprim.c";
static const unsigned char D_80095244[] = "Static Vertex stack overrun stack=%d max=%d %s %d\n";
static const unsigned char D_80095278[] = "mprim.c";
static const unsigned char D_80095280[] = "!!!!! WARNING !!!!!  YOUR USING TOO MANY FUCKING VERTICIES !!!!\n";
static const unsigned char D_800952C4[] = "Dynamic Vertex stack overrun stack=%d max=%d %s %d\n";
static const unsigned char D_800952F8[] = "mprim.c";

int func_80046F50(void)
{
    return D_80126B74 - D_80126B78;
}

unsigned int func_80046F68(void)
{
    return D_80126B74;
}

unsigned int func_80046F78(int bytes)
{
    D_80126B74 += bytes;
    if (D_80126B74 > D_80126B7C) {
        func_800496E0((unsigned char *)D_80095220, D_80126B74, D_8009523C, 0x19F);
    }
    return D_80126B74;
}

int func_80046FD8(void)
{
    return D_80126B80;
}

int func_80046FE8(int count)
{
    D_80126B80 += count;
    if (D_80126B80 > 2000) {
        func_800496E0((unsigned char *)D_80095244, D_80126B80, 2000, D_80095278, 0x1AF);
    }
    return D_80126B80;
}

int func_80047048(void)
{
    if (D_80126B84 - D_80123B20 > 9800) {
        func_80048DC0((char *)D_80095280);
        return -1;
    }
    return D_80126B84;
}

int func_80047094(int count)
{
    D_80126B84 += count;
    if (D_80126B84 > 22000) {
        func_800496E0((unsigned char *)D_800952C4, D_80126B84, 22000, D_800952F8, 0x1C4);
    }
    return D_80126B84;
}
