#include "../../../include/renderer_primitives_internal.h"
#include "../../../include/renderer_polygon_messages.h"


/* Excluded candidate; see docs/renderer-polygon-emission.md. */
void func_80045534(RendererMeshPrefix *mesh, RendererPosition *positions)
{
    short fourth;
    short third;
    short second;
    short first;
    int index;
    int used;
    int base;
    RendererPosition position;
    RendererPolygon *polygon;
    RendererPolygon *polygons = mesh->polygons;
    RendererNormal *normals = mesh->normals;

    base = D_80123AE4;
    used = mesh->vertexCount + base - D_80123B20;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095178, used, 10000, D_80095198, 0x3F6);
    }
    for (index = 0; index < mesh->vertexCount; index++) {
        position[0] = positions[index][0];
        D_800CDBD0[base + index].color.position[0] = position[0];
        position[1] = positions[index][1];
        D_800CDBD0[base + index].color.position[1] = position[1];
        position[2] = positions[index][2];
        D_800CDBD0[base + index].color.position[2] = position[2];
    }
    FRAME_COMMAND(0x04000000 | (((mesh->vertexCount << 10) |
                  (sizeof(RendererVertex) * mesh->vertexCount - 1)) & 0xFFFF),
                  &D_800CDBD0[base]);
    for (index = 0; index < mesh->polygonCount; index++) {
        polygon = &polygons[index];
        first = polygon->vertices[0];
        second = polygon->vertices[1];
        third = polygon->vertices[2];
        fourth = polygon->vertices[3];
        if (D_800C85B8 != 0) {
            func_80043E80(polygon);
            func_80043930(0, normals[polygon->normals[0]]);
            func_80043930(1, normals[polygon->normals[1]]);
            func_80043930(2, normals[polygon->normals[2]]);
            func_80043930(3, normals[polygon->normals[3]]);
        } else {
            func_80043D68(polygon);
            func_80043AA0(first, D_8007BB34[(polygon->colors[0] >> 24) & 0xFF]);
            func_80043AA0(second, D_8007BB34[(polygon->colors[1] >> 24) & 0xFF]);
            func_80043AA0(third, D_8007BB34[(polygon->colors[2] >> 24) & 0xFF]);
            func_80043AA0(fourth, D_8007BB34[(polygon->colors[3] >> 24) & 0xFF]);
        }
        if (polygon->vertexCount == 3) {
            RENDERER_TRIANGLE(first, second, third);
        } else {
            RENDERER_QUAD(first, second, third, fourth);
        }
    }
    D_80123AE4 += mesh->vertexCount;
}
