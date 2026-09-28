#include "../../include/fixed_geometry.h"

void func_8004D59C(int *output, FixedMatrix *matrix, int *positions, int count)
{
    int i;

    for (i = 0; i < count; i++) {
        output[0] = ((positions[0] * matrix->m[0][0]) >> 15) +
                    ((positions[1] * matrix->m[0][1]) >> 15) +
                    ((positions[2] * matrix->m[0][2]) >> 15);
        output[1] = ((positions[0] * matrix->m[1][0]) >> 15) +
                    ((positions[1] * matrix->m[1][1]) >> 15) +
                    ((positions[2] * matrix->m[1][2]) >> 15);
        output[2] = ((positions[0] * matrix->m[2][0]) >> 15) +
                    ((positions[1] * matrix->m[2][1]) >> 15) +
                    ((positions[2] * matrix->m[2][2]) >> 15);
        output += 3;
        positions += 3;
    }
}

void func_8004D884(FixedMatrix *output, FixedMatrix *left, FixedMatrix *right)
{
    output->m[0][0] = ((left->m[0][0] * right->m[0][0]) +
                       (left->m[0][1] * right->m[1][0]) +
                       (left->m[0][2] * right->m[2][0])) >> 15;
    output->m[0][1] = ((left->m[0][0] * right->m[0][1]) +
                       (left->m[0][1] * right->m[1][1]) +
                       (left->m[0][2] * right->m[2][1])) >> 15;
    output->m[0][2] = ((left->m[0][0] * right->m[0][2]) +
                       (left->m[0][1] * right->m[1][2]) +
                       (left->m[0][2] * right->m[2][2])) >> 15;
    output->m[1][0] = ((left->m[1][0] * right->m[0][0]) +
                       (left->m[1][1] * right->m[1][0]) +
                       (left->m[1][2] * right->m[2][0])) >> 15;
    output->m[1][1] = ((left->m[1][0] * right->m[0][1]) +
                       (left->m[1][1] * right->m[1][1]) +
                       (left->m[1][2] * right->m[2][1])) >> 15;
    output->m[1][2] = ((left->m[1][0] * right->m[0][2]) +
                       (left->m[1][1] * right->m[1][2]) +
                       (left->m[1][2] * right->m[2][2])) >> 15;
    output->m[2][0] = ((left->m[2][0] * right->m[0][0]) +
                       (left->m[2][1] * right->m[1][0]) +
                       (left->m[2][2] * right->m[2][0])) >> 15;
    output->m[2][1] = ((left->m[2][0] * right->m[0][1]) +
                       (left->m[2][1] * right->m[1][1]) +
                       (left->m[2][2] * right->m[2][1])) >> 15;
    output->m[2][2] = ((left->m[2][0] * right->m[0][2]) +
                       (left->m[2][1] * right->m[1][2]) +
                       (left->m[2][2] * right->m[2][2])) >> 15;
}
