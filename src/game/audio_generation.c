#include "../../include/audio_commands.h"
#include "../../include/audio_runtime.h"
#include "../../include/heap.h"

extern int D_8008D590[];
extern int D_8008D76C;
extern int D_8008D770;
extern void *D_8008D774;
extern int D_800AF1E0;
extern AudioHeap D_80190158;
extern int D_80190168;

int func_8005D4C8(int index);
void func_8005D584(int index, void *allocation);
void func_8005D610(int index);

void func_800515B0(int index, int unused)
{
    if (index < 0x88) {
        func_80053C50(D_8008D590[index]);
    }
}

void func_800515F0(void)
{
    int index;

    if (D_8008D76C != -1) {
        if (func_80053CC0(D_8008D76C) != 3) {
            if (D_80190168 == 1) {
                if (D_8008D770-- < 0) {
                    index = D_8008D76C;
                    D_8008D76C = -1;
                    func_80051680(index - 0x87, D_80190168);
                }
            } else {
                D_8008D76C = -1;
            }
        }
    }
}

void func_80051680(int value, int mode)
{
    int requested;
    int maxSize;
    int index;
    void *allocation;

    D_80190168 = mode;
    requested = value - 1;
    maxSize = 0;
    D_8014BE54 = 0x15F90;
    D_8014BE50 = func_8004DD6C(D_8014BE54);
    if (D_8014BE50 != 0) {
        if (requested < 0) {
            requested = 0;
        }
        requested = (requested % D_800AF1E0) + 0x88;
        if (requested != D_8008D76C) {
            if (D_8008D76C != -1) {
                func_80053EBC(D_8008D76C);
                while (func_80053CC0(D_8008D76C) == 3) {
                }
                func_8005D610(D_8008D76C);
            }
            allocation = D_8008D774;
            if (allocation == 0) {
                for (index = 0x88; index < 0x93; index++) {
                    if (maxSize < func_8005D4C8(index)) {
                        maxSize = func_8005D4C8(index);
                    }
                }
                D_8008D774 = func_80065730(0, 0, &D_80190158, 1, maxSize);
                allocation = D_8008D774;
            }
            if (allocation != 0) {
                func_8005D584(requested, allocation);
                func_80053C50(requested);
                D_8008D76C = requested;
                D_8008D770 = 0x14;
            } else {
                D_8008D76C = -1;
            }
        }
        func_8004DC70(D_8014BE50);
    }
}
