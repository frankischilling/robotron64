#include "../../include/sound_bridge_internal.h"

void func_800360F0(SoundDefinitionCommand *command)
{
    int index;
    int value00;
    int value04;
    int value08;
    int value10;
    int platformFlag;
    SoundDefinition *definition;

    index = command->index;
    value00 = command->value00;
    value04 = command->value04;
    value08 = command->value08;
    value10 = command->value10;
    platformFlag = command->platformFlag;
    definition = &D_800AE568[index];
    definition->value00 = value00;
    definition->value04 = value04;
    definition->value08 = value08;
    definition->value10 = value10;
    definition->platformFlag = platformFlag;
}

void func_80036138(int value)
{
    D_8009EFB4 = 1;
}
