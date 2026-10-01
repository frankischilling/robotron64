#ifndef ROBOTRON_OBJECT_DRAW_H
#define ROBOTRON_OBJECT_DRAW_H

#include "object.h"

typedef int (*ObjectDrawCallback)(unsigned int resource, ObjectRecord *object);

typedef struct ObjectResourceType {
    unsigned char kind;
    unsigned char unknown01;
    unsigned char variant;
} ObjectResourceType;

struct ObjectDrawResource {
    ObjectDrawCallback draw;
    unsigned char unknown04[0x1B];
    unsigned char mode1F;
    unsigned int unknown20;
    ObjectResourceType *type;
    unsigned char unknown28[0x20];
    int timestamp48;
    int historyCount4C;
    int historySlot50;
};

typedef struct ObjectModelFrame {
    unsigned char unknown00[10];
    short frame;
} ObjectModelFrame;

struct ObjectModel {
    unsigned char unknown00[0x1C];
    short modelIndex;
    unsigned char unknown1E[6];
    short drawMode;
    unsigned short unknown26;
    ObjectModelFrame *frames[1];
};

int func_8003A4F4(unsigned int resource, ObjectRecord *object);
int func_8003A540(unsigned int resource, ObjectRecord *object);
int func_8003A58C(unsigned int resource, ObjectRecord *object);
int func_8003A5D8(unsigned int resource, ObjectRecord *object);
int func_8003A624(unsigned int resource, ObjectRecord *object);
int func_8003A67C(unsigned int resource, ObjectRecord *object);
int func_8003A6C8(unsigned int resource, ObjectRecord *object);
int func_8003A720(unsigned int resource, ObjectRecord *object);
int func_8003A778(unsigned int force, ObjectRecord *object);
void func_8003A8A8(void);
void func_8003A8B0(void);
void func_8003A460(int object);

#endif
