#ifndef ROBOTRON_OBJECT_HELPERS_H
#define ROBOTRON_OBJECT_HELPERS_H

typedef struct ObjectCameraState {
    float value00;
    float angle04[3];
    float position10[3];
    float value1C;
    float scale20;
    float angle24[3];
    float position30[3];
    int value3C;
    int value40;
    int value44;
} ObjectCameraState;

extern ObjectCameraState D_800C8B88;
extern int D_800C86C0[];
extern float D_FLT_800C8BD0;
extern unsigned char D_800C8BD4;
extern unsigned char D_800C8BD5;
extern unsigned char D_800C8BD6;

float func_8003A1C8(float *value);
void func_8003A1E4(float value);
void func_8003A214(float value);
float func_8003A230(void);
void func_8003A240(float value);
void func_8003A24C(float value, float unused1, float unused2);
void func_8003A260(float *x, float *y, float *z);
void func_8003A28C(float *value);
void func_8003A29C(float *value);
void func_8003A2AC(float *value);
void func_8003A2BC(float *x, float *y, float *z);
int func_8003A2E8(void);
int func_8003A3F8(int object);

#endif
