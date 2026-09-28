#include "../../include/model_geometry_internal.h"

void func_8003EB7C(RendererMeshPrefix *mesh)
{
    RendererPolygon *polygons = mesh->polygons;
    RendererPolygon *polygon;
    RendererPosition *positions = D_800CA5A0;
    int index;
    short first;
    short second;
    short third;
    short fourth;

    for (index = 0; index < mesh->polygonCount; index++) {
        polygon = &polygons[index];
        first = polygon->vertices[0];
        second = polygon->vertices[1];
        third = polygon->vertices[2];
        fourth = polygon->vertices[3];
        if (polygon->vertexCount == 3) {
            func_80044270(&positions[first][0], &positions[second][0], &positions[third][0]);
        } else {
            func_800443A0(&positions[first][0], &positions[second][0], &positions[third][0], &positions[fourth][0]);
        }
    }
}
