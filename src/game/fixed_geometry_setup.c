#include "../../include/fixed_geometry.h"
#include "../../include/scalar_math.h"

float func_80063230(float angle);
float func_800633F0(float angle);

float func_8004CED0(float angle)
{
    return func_800633F0(angle);
}

int func_8004CEF0(int value)
{
    if (value < 0) {
        return -value;
    }
    return value;
}

float func_8004CF08(float angle)
{
    float numerator;

    numerator = func_80063230(angle);
    return numerator / func_800633F0(angle);
}

void func_8004CF40(FixedMatrix *output, FixedMatrix *matrix, int angle)
{
    FixedMatrix rotation;
    int cosine;
    int sine;

    cosine = func_8004DB60(angle);
    sine = func_8004DB88(angle);
    rotation.m[0][0] = 0x7FFF;
    rotation.m[0][1] = 0;
    rotation.m[0][2] = 0;
    rotation.m[1][2] = -sine;
    rotation.m[1][0] = 0;
    rotation.m[1][1] = cosine;
    rotation.m[2][0] = 0;
    rotation.m[2][1] = sine;
    rotation.m[2][2] = cosine;
    func_8004D884(output, matrix, &rotation);
}

void func_8004CFB8(int *output, FixedMatrix *matrix, ShortPosition *positions,
                   int count, int *translation)
{
    int i;

    for (i = 0; i < count; i++) {
        output[0] = translation[0] + (unsigned int)(
                    ((positions->x * matrix->m[0][0]) >> 15) +
                    ((positions->y * matrix->m[0][1]) >> 15) +
                    ((positions->z * matrix->m[0][2]) >> 15));
        output[1] = translation[1] + (unsigned int)(
                    ((positions->x * matrix->m[1][0]) >> 15) +
                    ((positions->y * matrix->m[1][1]) >> 15) +
                    ((positions->z * matrix->m[1][2]) >> 15));
        output[2] = translation[2] + (unsigned int)(
                    ((positions->x * matrix->m[2][0]) >> 15) +
                    ((positions->y * matrix->m[2][1]) >> 15) +
                    ((positions->z * matrix->m[2][2]) >> 15));
        output += 3;
        positions++;
    }
}

void func_8004D0DC(FixedMatrix *output, FixedMatrix *matrix, int angle)
{
    FixedMatrix rotation;
    int cosine;
    int sine;

    cosine = func_8004DB60(angle);
    sine = func_8004DB88(angle);
    rotation.m[0][0] = cosine;
    rotation.m[0][1] = 0;
    rotation.m[0][2] = sine;
    rotation.m[1][1] = 0x7FFF;
    rotation.m[1][0] = 0;
    rotation.m[1][2] = 0;
    rotation.m[2][0] = -sine;
    rotation.m[2][1] = 0;
    rotation.m[2][2] = cosine;
    func_8004D884(output, matrix, &rotation);
}

void func_8004D154(FixedMatrix *output, FixedMatrix *matrix, int angle)
{
    FixedMatrix rotation;
    int cosine;
    int sine;

    cosine = func_8004DB60(angle);
    sine = func_8004DB88(angle);
    rotation.m[0][0] = cosine;
    rotation.m[0][1] = -sine;
    rotation.m[0][2] = 0;
    rotation.m[1][0] = sine;
    rotation.m[1][1] = cosine;
    rotation.m[1][2] = 0;
    rotation.m[2][2] = 0x7FFF;
    rotation.m[2][0] = 0;
    rotation.m[2][1] = 0;
    func_8004D884(output, matrix, &rotation);
}

void func_8004D1CC(int *output, FixedMatrix *matrix, ShortPosition *positions,
                   int count)
{
    int i;

    for (i = 0; i < count; i++) {
        output[0] = ((positions->x * matrix->m[0][0]) >> 15) +
                    ((positions->y * matrix->m[0][1]) >> 15) +
                    ((positions->z * matrix->m[0][2]) >> 15);
        output[1] = ((positions->x * matrix->m[1][0]) >> 15) +
                    ((positions->y * matrix->m[1][1]) >> 15) +
                    ((positions->z * matrix->m[1][2]) >> 15);
        output[2] = ((positions->x * matrix->m[2][0]) >> 15) +
                    ((positions->y * matrix->m[2][1]) >> 15) +
                    ((positions->z * matrix->m[2][2]) >> 15);
        output += 3;
        positions++;
    }
}
