#include "../../include/actor_resource_internal.h"

typedef struct EarlyResourceArgumentView {
    int value00;
    unsigned char unknown04[0x3C0];
    int values[10];
} EarlyResourceArgumentView;

typedef struct EarlyResourceArgumentCommand {
    int opcode;
    int index;
    int value08;
    int values[10];
} EarlyResourceArgumentCommand;

typedef char EarlyResourceArgumentViewMustBe1004Bytes[
    sizeof(EarlyResourceArgumentView) == 1004 ? 1 : -1];
typedef char EarlyResourceArgumentCommandMustBe52Bytes[
    sizeof(EarlyResourceArgumentCommand) == 52 ? 1 : -1];

extern int D_8009EE04;

void func_8000EC30(EarlyResourceArgumentCommand *command)
{
    int i;
    int index = command->index;

    ((EarlyResourceArgumentView *)D_8009EA18)[index].value00 = 5;
    for (i = 0; i < 10; i++) {
        ((EarlyResourceArgumentView *)D_8009EA18)[index].values[i] = command->values[i];
    }
    D_8009EE04 = index;
}
