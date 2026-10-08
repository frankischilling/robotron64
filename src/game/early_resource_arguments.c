#include "../../include/actor_resource_internal.h"

typedef struct EarlyResourceArgumentCommand {
    int opcode;
    int index;
    int value08;
    int values[10];
} EarlyResourceArgumentCommand;

typedef char EarlyResourceArgumentCommandMustBe52Bytes[
    sizeof(EarlyResourceArgumentCommand) == 52 ? 1 : -1];

extern int D_8009EE04;

void func_8000EC30(EarlyResourceArgumentCommand *command)
{
    int i;
    int index = command->index;

    D_8009EA18[index].count = 5;
    for (i = 0; i < 10; i++) {
        D_8009EA18[index].parameters[i] = command->values[i];
    }
    D_8009EE04 = index;
}
