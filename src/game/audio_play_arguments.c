#include "../../include/audio_commands.h"

void func_80055760(int index, int value)
{
    func_8005396C(&D_801902EC->table->slots[index], index, value, 0, 0);
}

void func_800557A8(int index, int value, int argument)
{
    func_8005396C(&D_801902EC->table->slots[index], index, value, 0, argument);
}
