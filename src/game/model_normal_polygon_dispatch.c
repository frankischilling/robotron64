#include "../../include/model_geometry_internal.h"

typedef struct RendererPolygonIndexCache {
    int first;
    int second;
    int third;
    int fourth;
} RendererPolygonIndexCache;

typedef char RendererPolygonIndexCacheMustBe16Bytes[
    sizeof(RendererPolygonIndexCache) == 16 ? 1 : -1];

void func_8003EE20(RendererMeshPrefix *mesh)
{
    RendererPolygon *polygons = mesh->polygons;
    RendererPolygon *polygon;
    RendererPolygon *current;
    RendererNormal *normals = mesh->normals;
    RendererPosition *positions = D_800CA5A0;
    int index;
    RendererPolygonIndexCache indices;

    index = 0;
    if (mesh->polygonCount > 0) {
        current = polygons; do {
            polygon = current;
            indices.first = polygon->vertices[0];
            indices.second = polygon->vertices[1];
            indices.third = polygon->vertices[2];
            indices.fourth = polygon->vertices[3];
            func_80043E80(&polygons[index]);
            func_80043930(0, &normals[polygon->normals[0]][0]);
            func_80043930(1, &normals[polygon->normals[1]][0]);
            func_80043930(2, &normals[polygon->normals[2]][0]);
            func_80043930(3, &normals[polygon->normals[3]][0]);
            if (polygon->vertexCount == 3) {
                func_80044D84(&positions[indices.first][0], &positions[indices.second][0], &positions[indices.third][0]);
            } else {
                func_80044B18(&positions[indices.first][0], &positions[indices.second][0], &positions[indices.third][0], &positions[indices.fourth][0]);
            }
            current++;
            index++;
        } while (index < mesh->polygonCount);
    }
}

void func_8003EFC4(RendererMeshPrefix *mesh)
{
    RendererPolygon *polygons = mesh->polygons;
    RendererPolygon *polygon;
    RendererPolygon *current;
    RendererNormal *normals = mesh->normals;
    RendererPosition *positions = D_800CA5A0;
    int index;
    RendererPolygonIndexCache indices;

    index = 0;
    if (mesh->polygonCount > 0) {
        current = polygons; do {
            polygon = current;
            indices.first = polygon->vertices[0];
            indices.second = polygon->vertices[1];
            indices.third = polygon->vertices[2];
            indices.fourth = polygon->vertices[3];
            func_80043EEC(&polygons[index]);
            func_80043930(0, &normals[polygon->normals[0]][0]);
            func_80043930(1, &normals[polygon->normals[1]][0]);
            func_80043930(2, &normals[polygon->normals[2]][0]);
            func_80043930(3, &normals[polygon->normals[3]][0]);
            if (polygon->vertexCount == 3) {
                func_80044D84(&positions[indices.first][0], &positions[indices.second][0], &positions[indices.third][0]);
            } else {
                func_80044B18(&positions[indices.first][0], &positions[indices.second][0], &positions[indices.third][0], &positions[indices.fourth][0]);
            }
            current++;
            index++;
        } while (index < mesh->polygonCount);
    }
}
