#include "../../include/renderer_geometry_internal.h"

void func_80045F40(int first, int count, int destination)
{
    int index;

    for (index = 0; index < count; index++, first++, destination++) {
        D_800CDBD0[destination].color.position[0] = D_800CA5A0[first][0];
        D_800CDBD0[destination].color.position[1] = D_800CA5A0[first][1];
        D_800CDBD0[destination].color.position[2] = D_800CA5A0[first][2];
        D_800CDBD0[destination].color.color[0] = D_80123AF0;
        D_800CDBD0[destination].color.color[1] = D_80123AF4;
        D_800CDBD0[destination].color.color[2] = D_80123AF8;
        D_800CDBD0[destination].color.color[3] = 64;
    }
}

void func_800460D8(int first, int count, int destination, RendererNormal *normals)
{
    int index;

    for (index = 0; index < count; index++, first++, destination++) {
        D_800CDBD0[destination].normal.position[0] = D_800CA5A0[first][0];
        D_800CDBD0[destination].normal.position[1] = D_800CA5A0[first][1];
        D_800CDBD0[destination].normal.position[2] = D_800CA5A0[first][2];
        D_800CDBD0[destination].normal.normal[0] = normals[first][0] >> 8;
        D_800CDBD0[destination].normal.normal[1] = normals[first][1] >> 8;
        D_800CDBD0[destination].normal.normal[2] = normals[first][2] >> 8;
        D_800CDBD0[destination].normal.alpha = 64;
    }
}
