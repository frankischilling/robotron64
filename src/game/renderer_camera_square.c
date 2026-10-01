#include "../../include/model_geometry_internal.h"

void func_80045214(int *first, int *second, int *third, int *fourth);

void func_80043070(int x, int z)
{
    RendererPosition first;
    RendererPosition second;
    RendererPosition third;
    RendererPosition fourth;
    RendererPosition transformedFirst;
    RendererPosition transformedSecond;
    RendererPosition transformedThird;
    RendererPosition transformedFourth;
    RendererVertex *vertices;

    first[0] = (1660 - D_800C8BD8.position[0] + x) >> 1;
    first[1] = -D_800C8BD8.position[1] >> 1;
    first[2] = (1660 - D_800C8BD8.position[2] + z) >> 1;
    second[0] = (1660 - D_800C8BD8.position[0] + x) >> 1;
    second[1] = -D_800C8BD8.position[1] >> 1;
    second[2] = (-1660 - D_800C8BD8.position[2] + z) >> 1;
    third[0] = (-1660 - D_800C8BD8.position[0] + x) >> 1;
    third[1] = -D_800C8BD8.position[1] >> 1;
    third[2] = (-1660 - D_800C8BD8.position[2] + z) >> 1;
    fourth[0] = (-1660 - D_800C8BD8.position[0] + x) >> 1;
    fourth[1] = -D_800C8BD8.position[1] >> 1;
    fourth[2] = (1660 - D_800C8BD8.position[2] + z) >> 1;
    func_8004D4B4(transformedFirst, &D_800CD250, first);
    func_8004D4B4(transformedSecond, &D_800CD250, second);
    func_8004D4B4(transformedThird, &D_800CD250, third);
    func_8004D4B4(transformedFourth, &D_800CD250, fourth);
    vertices = &D_800CDBD0[D_80123AE4];
    vertices[0].color.texture[0] = 0;
    vertices[0].color.texture[1] = 0;
    vertices[1].color.texture[0] = 3968;
    vertices[1].color.texture[1] = 0;
    vertices[2].color.texture[0] = 3968;
    vertices[2].color.texture[1] = 3968;
    vertices[3].color.texture[1] = 3968;
    vertices[3].color.texture[0] = 0;
    func_80045214(transformedFirst, transformedSecond, transformedThird,
                  transformedFourth);
}
