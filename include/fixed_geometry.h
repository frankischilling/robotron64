#ifndef ROBOTRON_FIXED_GEOMETRY_H
#define ROBOTRON_FIXED_GEOMETRY_H

#include "fixed_math.h"

typedef struct ShortPosition {
    short x;
    short y;
    short z;
    short unknown6;
} ShortPosition;

typedef char ShortPositionMustBe8Bytes[sizeof(ShortPosition) == 8 ? 1 : -1];

void func_8004CF40(FixedMatrix *output, FixedMatrix *matrix, int angle);
void func_8004CFB8(int *output, FixedMatrix *matrix, ShortPosition *positions,
                   int count, int *translation);
void func_8004D0DC(FixedMatrix *output, FixedMatrix *matrix, int angle);
void func_8004D154(FixedMatrix *output, FixedMatrix *matrix, int angle);
void func_8004D1CC(int *output, FixedMatrix *matrix, ShortPosition *positions,
                   int count);
void func_8004D59C(int *output, FixedMatrix *matrix, int *positions, int count);
void func_8004D884(FixedMatrix *output, FixedMatrix *left, FixedMatrix *right);

#endif
