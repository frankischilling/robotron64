#ifndef ROBOTRON_GEOMETRY_BRIDGE_INTERNAL_H
#define ROBOTRON_GEOMETRY_BRIDGE_INTERNAL_H

#include "fixed_geometry.h"

typedef struct GeometryPoint {
    int x;
    int y;
    int z;
} GeometryPoint;

typedef char GeometryPointMustBe12Bytes[
    sizeof(GeometryPoint) == 12 ? 1 : -1];

extern unsigned char D_800CA5A0[];
extern int D_8007CDC0;
extern int D_800CD2A0;

void func_8003FA18(GeometryPoint *output, GeometryPoint *input, int count, int value);
void func_8003FC14(GeometryPoint *output, GeometryPoint *input, int count, int value);
void func_8003D170(int count);
void func_8003D1A4(int count);
void func_8003D1D8(int count);
void func_8003D20C(int *position, int *angles);

#endif
