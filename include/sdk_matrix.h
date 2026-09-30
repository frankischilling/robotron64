#ifndef ROBOTRON_SDK_MATRIX_H
#define ROBOTRON_SDK_MATRIX_H

typedef union SdkMatrix {
    int words[4][4];
    long long alignment;
} SdkMatrix;

typedef char SdkMatrixMustBe64Bytes[sizeof(SdkMatrix) == 64 ? 1 : -1];

void func_80068250(float matrix[4][4], SdkMatrix *fixed);
void func_80068350(float matrix[4][4]);
void func_800683D8(SdkMatrix *fixed);
void func_80068408(float matrix[4][4], SdkMatrix *fixed);
void func_80061210(float matrix[4][4], float x, float y, float z);
void func_80061258(SdkMatrix *fixed, float x, float y, float z);

#endif
