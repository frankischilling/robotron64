#include "../../include/scheduler_runtime.h"
#include "../../include/audio_commands.h"
#include "../../include/audio_runtime.h"

extern void func_80055214(int, int);
extern void func_800554F4(int);
extern int func_8005FB08(int, int, void *, int);

void func_80050FB0(int value)
{
    func_80053C50(value);
}

void func_80050FD0(void)
{
    func_80054268();
}

void func_80050FF0(void)
{
    func_80055214(1, 3);
}

void func_80051014(void)
{
    func_800554F4(1);
}

void func_80051034(int arg0, int arg1, int arg2)
{
}

int func_80051044(int arg0, int arg1, int arg2, int arg3)
{
    if (func_8005FB08(arg1 + arg2, arg3, D_8014BE50, D_8014BE54) != 0) {
        return -1;
    }
    return 0;
}
