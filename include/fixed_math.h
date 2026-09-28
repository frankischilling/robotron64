#ifndef ROBOTRON_FIXED_MATH_H
#define ROBOTRON_FIXED_MATH_H

typedef struct FixedMatrix {
    int m[3][3];
} FixedMatrix;

void func_8004D4B4(int *output, FixedMatrix *matrix, int *position);
void func_8004DB34(FixedMatrix *matrix);
int func_8004DB60(int angle);
int func_8004DB88(int angle);
int func_8004DBB0(int scale, int angle);
int func_8004DBE4(int scale, int angle);
int func_8004DC18(int angle);

#endif
