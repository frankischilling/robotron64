#include "../../include/object_draw.h"
#include "../../include/renderer_object_glyph_internal.h"
#include "../../include/menu_label_internal.h"
#include "../../include/palette.h"

/* Packed colors use the same big-endian byte layout as the palette. */
extern void *D_800AEE9C;
extern unsigned char D_8007751C[];
extern unsigned char D_800773C4[];
extern unsigned char D_800772F0[];
extern unsigned char D_80077BCC[];
extern unsigned char D_80077B70[];
extern unsigned char D_80076BD8[];
extern unsigned char D_8007726C[];
extern unsigned char D_80076B70[];
extern unsigned char D_80076BA4[];
extern unsigned char D_80076B14[];
extern unsigned char D_800766BC[];
extern unsigned char D_800763F0[];
extern unsigned char D_8007628C[];

extern void func_80049DF4(int, int, int);

int func_8003A778(unsigned int force, ObjectRecord *object)
{
    int index = object->unknown0C[5];
    int value;

    func_80049DF4(((unsigned char *)&D_8007BF34[index])[0], ((unsigned char *)&D_8007BF34[index])[1],
                  ((unsigned char *)&D_8007BF34[index])[2]);
    value = object->unknown0C[4];
    if (D_800AEE9C == D_8007751C ||
        D_800AEE9C == D_800773C4 ||
        D_800AEE9C == D_800772F0 ||
        D_800AEE9C == D_80077BCC ||
        D_800AEE9C == D_80077B70 ||
        D_800AEE9C == D_80076BD8 ||
        D_800AEE9C == &D_800AF1A8 ||
        D_800AEE9C == D_8007726C ||
        D_800AEE9C == D_80076B70 ||
        D_800AEE9C == D_80076BA4 ||
        D_800AEE9C == D_80076B14 ||
        D_800AEE9C == D_800766BC ||
        D_800AEE9C == D_800763F0 ||
        D_800AEE9C == D_8007628C ||
        force == 1) {
        return func_8004A2B4((RendererDrawState *)&object->draw38, value, 1);
    } else {
        return func_8004A2B4((RendererDrawState *)&object->draw38, value, 0);
    }
}

void func_8003A8A8(void)
{
}
