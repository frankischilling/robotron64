#include "../../include/sdk_matrix.h"

void func_80068408(float matrix[4][4], SdkMatrix *fixed)
{
    int row;
    int pair;
    unsigned int firstWord;
    unsigned int secondWord;
    unsigned int *integer;
    unsigned int *fraction;
    int first;
    int second;

    integer = (unsigned int *)&fixed->words[0][0];
    fraction = (unsigned int *)&fixed->words[2][0];
    for (row = 0; row < 4; row++) {
        for (pair = 0; pair < 2; pair++) {
            firstWord = (*integer & 0xFFFF0000) | ((*fraction >> 16) & 0xFFFF);
            secondWord = ((*integer << 16) & 0xFFFF0000) | (*fraction & 0xFFFF);
            first = *(int *)&firstWord;
            second = *(int *)&secondWord;
            matrix[row][2 * pair] = (float)first / 65536.0f;
            matrix[row][2 * pair + 1] = (float)second / 65536.0f;
            integer++;
            fraction++;
        }
    }
}

void func_80068350(float matrix[4][4])
{
    int row;
    int column;

    for (row = 0; row < 4; row++) {
        for (column = 0; column < 4; column++) {
            if (row == column) {
                matrix[row][column] = 1.0f;
            } else {
                matrix[row][column] = 0.0f;
            }
        }
    }
}

void func_800683D8(SdkMatrix *fixed)
{
    float matrix[4][4];

    func_80068350(matrix);
    func_80068250(matrix, fixed);
}

void func_80068250(float matrix[4][4], SdkMatrix *fixed)
{
    int first;
    int second;
    int *integer;
    int *fraction;
    int row;
    int pair;

    integer = &fixed->words[0][0];
    fraction = &fixed->words[2][0];
    for (row = 0; row < 4; row++) {
        for (pair = 0; pair < 2; pair++) {
            first = matrix[row][2 * pair] * 65536.0f;
            second = matrix[row][2 * pair + 1] * 65536.0f;
            *integer++ = (first & 0xFFFF0000) | ((second >> 16) & 0xFFFF);
            *fraction++ = ((first << 16) & 0xFFFF0000) | (second & 0xFFFF);
        }
    }
}
