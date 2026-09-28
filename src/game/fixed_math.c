#include "../../include/fixed_math.h"
#include "../../include/sdk_math.h"

extern int D_8008D370[];

void func_8004DB34(FixedMatrix *matrix)
{
    matrix->m[0][0] = 0x7FFF;
    matrix->m[1][0] = 0;
    matrix->m[2][0] = 0;
    matrix->m[0][1] = 0;
    matrix->m[1][1] = 0x7FFF;
    matrix->m[2][1] = 0;
    matrix->m[0][2] = 0;
    matrix->m[1][2] = 0;
    matrix->m[2][2] = 0x7FFF;
}

int func_8004DB60(int angle)
{
    return func_8005FC20(angle << 4);
}

int func_8004DB88(int angle)
{
    return func_8005FBB0(angle << 4);
}

int func_8004DBB0(int scale, int angle)
{
    return (func_8005FC20(angle) * scale) >> 15;
}

int func_8004DBE4(int scale, int angle)
{
    return (func_8005FBB0(angle) * scale) >> 15;
}

int func_8004DC18(int angle)
{
    int result;

    angle = (angle >> 3) & 0x1FF;
    if (angle <= 0x100) {
        result = D_8008D370[angle];
    } else {
        result = -D_8008D370[0x200 - angle];
    }
    return result;
}
