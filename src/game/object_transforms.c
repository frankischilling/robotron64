#include "../../include/object.h"

ObjectTransform *func_800394C0(int object, float value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->position[0] = value;
    record->position[0] = value * 12.0f;
    return transform;
}

ObjectTransform *func_80039514(int object, int value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->angle[1] = (value - 1024) * D_FLT_80094C20 / 2048;
    record->angle[1] = (1024 - value) & 0xffd;
    return transform;
}

ObjectTransform *func_8003956C(int object, float value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->position[1] = value;
    record->position[1] = value * 12.0f;
    return transform;
}

ObjectTransform *func_800395C0(int object, float value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->position[2] = value;
    record->position[2] = value * 12.0f;
    return transform;
}

ObjectTransform *func_80039614(int object, float *value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->position[0] = value[0];
    transform->position[1] = value[1];
    transform->position[2] = value[2];
    record->position[0] = value[0] * 12.0f;
    record->position[1] = value[1] * 12.0f;
    record->position[2] = value[2] * 12.0f;
    return transform;
}

ObjectTransform *func_800396F4(int object, int value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->angle[0] = value * D_FLT_80094C24 / 2048;
    record->angle[0] = value & 0xffd;
    return transform;
}

ObjectTransform *func_80039740(int object, int value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->angle[2] = value * D_FLT_80094C28 / 2048;
    record->angle[2] = value & 0xffd;
    return transform;
}

ObjectTransform *func_8003978C(int object, float value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->scale = value;
    record->scale[0] = value * 4.0f;
    return transform;
}

ObjectTransform *func_800397E0(int object, float value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->scale = value;
    record->scale[1] = value * 4.0f;
    return transform;
}

ObjectTransform *func_80039834(int object, float value)
{
    ObjectTransform *transform;
    ObjectRecord *record;
    record = &D_800BF918[object];
    transform = record->transform;
    transform->scale = value;
    record->scale[2] = value * 4.0f;
    return transform;
}

float func_80039888(int object, float *value)
{
    ObjectTransform *transform = D_800BF918[object].transform;
    *value = transform->scale;
    return *value;
}

float func_800398BC(int object, float *value)
{
    ObjectTransform *transform = D_800BF918[object].transform;
    *value = transform->scale;
    return *value;
}

float func_800398F0(int object, float *value)
{
    ObjectTransform *transform = D_800BF918[object].transform;
    *value = transform->scale;
    return *value;
}

float func_80039924(int object, float *value)
{
    ObjectTransform *transform = D_800BF918[object].transform;
    *value = transform->angle[0];
    return *value;
}

float func_80039958(int object, float *value)
{
    ObjectTransform *transform = D_800BF918[object].transform;
    *value = transform->angle[1];
    return *value;
}

float func_8003998C(int object, float *value)
{
    ObjectTransform *transform = D_800BF918[object].transform;
    *value = transform->angle[2];
    return *value;
}

void func_800399C0(int object, int unused)
{

}

void func_800399CC(int object, int unused)
{

}

void func_800399D8(int object, int unused)
{

}

ObjectTransform *func_800399E4(int object, float value)
{
    ObjectRecord *record;
    ObjectTransform *transform;
    int scale;
    record = &D_800BF918[object];
    scale = value * 4.0f;
    transform = record->transform;
    transform->scale = value;
    record->scale[0] = scale;
    record->scale[1] = scale;
    record->scale[2] = scale;
    return transform;
}


float func_80039A40(int object)
{
    return D_800BF918[object].transform->position[2];
}
float func_80039A68(int object)
{
    return D_800BF918[object].transform->position[0];
}
int func_80039A90(int object)
{
    return (int)(D_800BF918[object].transform->angle[0] * 2048 / D_DBL_80094C30) & 0xfff;
}
int func_80039B00(int object)
{
    return ((int)(D_800BF918[object].transform->angle[1] * 2048 / D_DBL_80094C38) + 1024) & 0xfff;
}
int func_80039B74(int object)
{
    return (int)(D_800BF918[object].transform->angle[2] * 2048 / D_DBL_80094C40) & 0xfff;
}
void func_80039BE4(int object, int unused)
{
}
void func_80039BF0(int object, int unused)
{
}
void func_80039BFC(int object, unsigned char value)
{
    ObjectRecord *record = &D_800BF918[object];
    record->property12 = value;
}
ObjectRecord *func_80039C1C(int object, int x, int y, int z)
{
    ObjectRecord *record = &D_800BF918[object];
    record->value04[0] = x;
    record->value04[1] = y;
    record->value04[2] = z;
    return record;
}
void func_80039C44(int object, int unused)
{
}
void func_80039C50(int object, int unused)
{
}
void func_80039C5C(int object, int value)
{
    D_800BF918[object].value0A = value;
}
