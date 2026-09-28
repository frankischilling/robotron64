#ifndef ROBOTRON_MODEL_GEOMETRY_INTERNAL_H
#define ROBOTRON_MODEL_GEOMETRY_INTERNAL_H

#include "renderer_primitives_internal.h"
#include "fixed_geometry.h"

/* Model nodes contain up to 30 child indices and a contiguous vertex range. */
typedef struct ModelGeometryNode {
    int position[3];
    unsigned char unknown0C[0x12];
    short children[30];
    short childCount;
    unsigned char unknown5C[4];
    short vertexCount;
    short vertexStart;
} ModelGeometryNode;

typedef char ModelGeometryNodeMustBe100Bytes[
    sizeof(ModelGeometryNode) == 0x64 ? 1 : -1];

extern RendererNormal *D_800CD29C;
extern FixedMatrix D_800CD250;
extern int D_800CD2A0;
extern int D_8007C5B4;
extern int D_8007C5B8;

void func_8003D2C0(int x, int y, int z, FixedMatrix *matrix);
void func_800444F8(int *first, int *second, int *third);
void func_800447D0(int *first, int *second, int *third, int *fourth);
void func_80044D84(int *first, int *second, int *third);
void func_80044B18(int *first, int *second, int *third, int *fourth);

#endif
