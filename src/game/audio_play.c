#include "../../include/audio_commands.h"

void func_80053C50(int index)
{
    func_80055760(index, 0);
}

void func_80053C70(int index, int argument)
{
    func_8005396C(&D_801902EC->table->slots[index], index, 0, 0, argument);
}
