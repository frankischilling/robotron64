#include "../../include/text.h"
int func_800013D0(int slot, TextRunProperty *properties)
{
    int inRun = 0;
    int run = 0;
    int index;
    int character;
    int object;
    TextRecord *record;
    if (slot >= 0) {
        record = &D_800B6FF8[slot];
        for (index = 0; index < record->length; index++) {
            character = record->text[index];
            if ((character >= '0' && character <= '9') || (character >= 0xaa && character <= 0xb3)) {
                if (!inRun) {
                    inRun = 1;
                }
                object = record->objects[index];
                if (object >= 0) {
                    func_80039E80(object, properties[run].value);
                }
            } else if (inRun) {
                inRun = 0;
                run++;
            }
        }
    }
    return (inRun == 1 ? 1 : 0) + run;
}
int func_800014FC(int slot, TextRunProperty *properties)
{
    int run = 0;
    int inRun = 0;
    int index;
    int object;
    TextRecord *record;
    int space = ' ';
    if (slot >= 0) {
        record = &D_800B6FF8[slot];
        for (index = 0; index < record->length; index++) {
            if (space != record->text[index]) {
                if (!inRun) {
                    inRun = 1;
                }
                object = record->objects[index];
                if (object >= 0 && run == properties->run) {
                    func_80039E80(object, properties->value);
                }
            } else if (inRun) {
                inRun = 0;
                if (run == properties->run) {
                    properties++;
                }
                run++;
            }
        }
    }
    return (inRun == 1 ? 1 : 0) + run;
}
void func_80001638(int slot, int value)
{
    TextRecord *record;
    int index;
    int object;
    if (slot >= 0) {
        record = &D_800B6FF8[slot];
        record->property64 = value;
        for (index = 0; index < record->length; index++) {
            object = record->objects[index];
            if (object >= 0) {
                func_80039E80(object, (unsigned char)value);
            }
        }
    }
}
