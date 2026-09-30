#include "../../include/movie.h"
#include "../../include/command_script.h"

unsigned char *func_800383C4(int identifier);

CommandScriptEntry D_80078150[] = {
    {func_800327AC, 1},
    {func_80003184, 2},
    {func_80003040, 6},
    {func_80003278, 4},
    {func_800033C8, 1},
    {func_800034A8, 2},
    {func_800036A4, 5},
    {func_80003510, 6},
    {func_80003408, 2},
    {func_8000367C, 2},
    {func_80003654, 2},
    {func_800032EC, 3},
    {func_800037DC, 0},
};

void func_800044AC(unsigned char *filename)
{
    int index;

    D_800B14A8 = &D_800B14B0;
    func_8003264C(filename, D_80078150, 0);
    for (index = 0; index < D_800B14A8->pairCount; index++) {
        if (D_800B14A8->pairs[index].identifier != -1) {
            D_800B14A8->pairs[index].track =
                func_80003A7C(D_800B14A8->pairs[index].identifier,
                               func_800383C4(D_800B14A8->pairs[index].identifier));
        }
    }
    for (index = 0; index < D_800B14A8->stringCount; index++) {
        D_800B14A8->strings[index].field08 =
            func_80003A7C(D_800B14A8->strings[index].field0C,
                           func_800383C4(D_800B14A8->strings[index].field0C));
    }
}
