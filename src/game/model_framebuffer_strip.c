#include "../../include/model_geometry_internal.h"

extern int D_800CD3B8;
extern int D_8007D914;
extern void *D_80138260[2];
void func_80040874(unsigned int address);

void func_80040724(int x, int y)
{
    int scaled;
    unsigned short *image;
    int first[3];
    int second[3];
    int third[3];
    int fourth[3];

    x -= 160;
    y -= 120;
    scaled = x * 100;
    first[0] = scaled;
    second[0] = scaled + 16000;
    fourth[0] = scaled;
    scaled = y * 100;
    first[1] = scaled;
    second[1] = scaled;
    third[0] = x + 160;
    third[1] = scaled + 600;
    fourth[1] = y + 6;
    third[0] *= 100;
    fourth[1] *= 100;
    first[2] = D_800CD3B8;
    second[2] = D_800CD3B8;
    third[2] = D_800CD3B8;
    fourth[2] = D_800CD3B8;
    func_80043CB4(0, 320, 10, 6);
    func_80043CB4(1, 0, 10, 6);
    func_80043CB4(2, 0, 0, 6);
    func_80043CB4(3, 320, 0, 6);
    image = D_80138260[D_8007D914 ^ 1];
    y += 120;
    func_80040874((unsigned int)(image + x + (74880 - y * 320)));
    func_80044F60(first, second, third, fourth);
}
