#include "../../../include/renderer_primitives_internal.h"
#include "../../../include/renderer_polygon_messages.h"

void func_80045534(RendererMeshPrefix *mesh, RendererPosition *positions)
{
    short fourth;
    short third;
    short second;
    short first;
    int index;
    int used;
    int base;
    RendererPolygon *polygon;
    RendererPolygon *polygons = mesh->polygons;
    RendererNormal *normals = mesh->normals;

    base = D_80123AE4;
    used = mesh->vertexCount + base - D_80123B20;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095178, used, 10000, D_80095198, 0x3F6);
    }
    for (index = 0; index < mesh->vertexCount; index++) {
        D_800CDBD0[base + index].color.position[0] = positions[index][0];
        D_800CDBD0[base + index].color.position[1] = positions[index][1];
        D_800CDBD0[base + index].color.position[2] = positions[index][2];
    }
    FRAME_COMMAND(0x04000000 | (((mesh->vertexCount << 10) |
                  (sizeof(RendererVertex) * mesh->vertexCount - 1)) & 0xFFFF),
                  &D_800CDBD0[base]);
    {
        RendererPolygon *entry;
        entry = polygons;
        polygon = polygons;
        for (index = 0; index < mesh->polygonCount; index++) {
            first = entry->vertices[0];
            second = entry->vertices[1];
            third = entry->vertices[2];
            fourth = entry->vertices[3];
            if (D_800C85B8 != 0) {
                func_80043E80(polygon);
                func_80043930(0, (short *)((unsigned char *)normals + entry->normals[0] * 8));
                func_80043930(1, (short *)((unsigned char *)normals + entry->normals[1] * 8));
                func_80043930(2, (short *)((unsigned char *)normals + entry->normals[2] * 8));
                func_80043930(3, (short *)((unsigned char *)normals + entry->normals[3] * 8));
            } else {
                func_80043D68(polygon);
                func_80043AA0(first, D_8007BB34[(entry->colors[0] >> 24) & 0xFF]);
                func_80043AA0(second, D_8007BB34[(entry->colors[1] >> 24) & 0xFF]);
                func_80043AA0(third, D_8007BB34[(entry->colors[2] >> 24) & 0xFF]);
                func_80043AA0(fourth, D_8007BB34[(entry->colors[3] >> 24) & 0xFF]);
            }
            if (entry->vertexCount == 3) {
                RENDERER_TRIANGLE(first, second, third);
            } else {
                RENDERER_QUAD(first, second, third, fourth);
            }
            entry++;
            polygon++;
        }
    }
    D_80123AE4 += mesh->vertexCount;
}
