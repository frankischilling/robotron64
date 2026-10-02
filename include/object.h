#ifndef ROBOTRON_OBJECT_H
#define ROBOTRON_OBJECT_H

/* Partial layouts recovered from transform accessors; object stride is 120 bytes. */
typedef struct ObjectTransform {
    float scale;
    float angle[3];
    float position[3];
} ObjectTransform;
typedef struct ObjectDrawResource ObjectDrawResource;
typedef struct ObjectModel ObjectModel;
typedef struct ObjectRecord {
    short unknown00;
    short index02;
    short value04[3];
    short value0A;
    unsigned char unknown0C[6];
    unsigned char property12;
    unsigned char enabled13;
    unsigned char unknown14[2];
    unsigned short value16;
    ObjectTransform *transform;
    ObjectTransform localTransform;
    unsigned int draw38;
    int scale[3];
    int angle[3];
    int position[3];
    unsigned char unknown60[12];
    ObjectDrawResource *drawResource;
    int drawValue70;
    ObjectModel *model;
} ObjectRecord;

typedef char ObjectRecordMustBe120Bytes[sizeof(ObjectRecord) == 0x78 ? 1 : -1];
int func_8003921C(int type, int count, ObjectDrawResource *draw,
                  ObjectModel *model);

extern ObjectRecord D_800BF918[];
extern float D_FLT_80094C20;
extern float D_FLT_80094C24;
extern float D_FLT_80094C28;

ObjectTransform *func_800394C0(int object, float value);
void func_80039514(int object, int value);
ObjectTransform *func_8003956C(int object, float value);
ObjectTransform *func_800395C0(int object, float value);
ObjectTransform *func_80039614(int object, float *value);
ObjectTransform *func_800396F4(int object, int value);
ObjectTransform *func_80039740(int object, int value);
ObjectTransform *func_8003978C(int object, float value);
ObjectTransform *func_800397E0(int object, float value);
ObjectTransform *func_80039834(int object, float value);
float func_80039888(int object, float *value);
float func_800398BC(int object, float *value);
float func_800398F0(int object, float *value);
float func_80039924(int object, float *value);
float func_80039958(int object, float *value);
float func_8003998C(int object, float *value);
void func_800399C0(int object, int unused);
void func_800399CC(int object, int unused);
void func_800399D8(int object, int unused);
void func_800399E4(int object, float value);

extern double D_DBL_80094C30;
extern double D_DBL_80094C38;
extern double D_DBL_80094C40;

float func_80039A40(int object);
float func_80039A68(int object);
int func_80039A90(int object);
int func_80039B00(int object);
int func_80039B74(int object);
void func_80039BE4(int object, int unused);
void func_80039BF0(int object, int unused);
int func_80039BFC(int object, unsigned char value);
ObjectRecord *func_80039C1C(int object, int x, int y, int z);
void func_80039C44(int object, int unused);
void func_80039C50(int object, int unused);
void func_80039C5C(int object, int value);

#endif
