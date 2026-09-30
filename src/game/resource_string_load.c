#include "../../include/resource_strings.h"

void func_80038498(unsigned char *name)
{
    short *offsets;
    unsigned char *strings;
    unsigned char path[100];
    int size;

    func_8003B6E4(path, name);
    func_8003B6E4(func_8003B4C0(path, '.'), D_80094BC4);
    offsets = func_8003C64C(path, &size);
    D_800A42A8 = *offsets;
    func_8003B520(D_800A3AD8, offsets + 1, D_800A42A8 * 2);
    func_8003C698(offsets);
    func_8003B6E4(func_8003B4C0(path, '.'), D_80094BCC);
    strings = func_8003C64C(path, &size);
    func_8003B520(D_8009FC50, strings, size);
    func_8003C698(strings);
}
