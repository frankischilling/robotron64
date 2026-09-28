#include "../../include/model_geometry_internal.h"

void func_8003EC98(RendererMeshPrefix *mesh)
{
    RendererPolygon *polygons = mesh->polygons;
    RendererPolygon *polygon;
    unsigned int *color;
    unsigned int packedColor;
    RendererPosition *positions = D_800CA5A0;
    int index;
    short first;
    short second;
    short third;
    short fourth;

    for (index = 0; index < mesh->polygonCount; index++) {
        polygon = &polygons[index];
        packedColor = polygon->colors[0];
        color = &D_8007BB34[(packedColor >> 24) & 0xFF];
        first = polygon->vertices[0];
        second = polygon->vertices[1];
        third = polygon->vertices[2];
        fourth = polygon->vertices[3];
        func_80043AA0(0, *color);
        func_80043AA0(1, *color);
        func_80043AA0(2, *color);
        func_80043AA0(3, *color);
        if (polygon->vertexCount == 3) {
            func_800444F8(&positions[first][0], &positions[second][0], &positions[third][0]);
        } else {
            func_800447D0(&positions[first][0], &positions[second][0], &positions[third][0], &positions[fourth][0]);
        }
    }
}
