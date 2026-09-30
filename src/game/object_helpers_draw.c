#include "../../include/object_draw.h"

extern int D_800C85B8;
extern int D_800BF904;
extern int D_800BF6F8;
extern int D_800BF900;
extern int D_800BF5F0;

extern int func_8003D43C(void *, int, int, int, int);
extern int func_8003D7F4(void *, int, int, int, int);
extern int func_8003E220(void *, int, int, int, int);
extern int func_8003DB7C(void *, int, int, int, int);
extern int func_8003DF38(void *, int, int, int, int);
extern int func_8003E8D0(void *, int, int, int, int);
extern int func_8003E6A0(void *, int, int, int, int);

int func_8003A4F4(unsigned int unused, ObjectRecord *object)
{
    return func_8003D43C(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A540(unsigned int unused, ObjectRecord *object)
{
    return func_8003D43C(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A58C(unsigned int unused, ObjectRecord *object)
{
    return func_8003D7F4(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A5D8(unsigned int unused, ObjectRecord *object)
{
    return func_8003E220(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A624(unsigned int unused, ObjectRecord *object)
{
    D_800BF5F0 = object->drawValue70;
    return func_8003DB7C(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A67C(unsigned int unused, ObjectRecord *object)
{
    return func_8003DF38(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A6C8(unsigned int unused, ObjectRecord *object)
{
    D_800BF5F0 = object->drawValue70;
    return func_8003E8D0(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}

int func_8003A720(unsigned int unused, ObjectRecord *object)
{
    D_800BF5F0 = object->drawValue70;
    return func_8003E6A0(&object->draw38, D_800BF904, D_800BF6F8,
                  D_800BF900, D_800C85B8);
}
