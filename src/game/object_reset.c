#include "../../include/object_draw.h"
#include "../../include/game_memory.h"

void func_8003A460(int object)
{
    ObjectRecord *record = &D_800BF918[object];

    func_8003B694(record, 0, sizeof(ObjectRecord));
    D_800BF918[object].index02 = 1;
    D_800BF918[object].enabled13 = 3;
    D_800BF918[object].unknown14[0] = 0;
    D_800BF918[object].value16 = 0;
    D_800BF918[object].unknown0C[5] = 0x30;
    D_800BF918[object].value0A = -1;
    D_800BF918[object].transform = &D_800BF918[object].localTransform;
    D_800BF918[object].angle[0] = 0;
    D_800BF918[object].angle[1] = 0;
    D_800BF918[object].angle[2] = 0;
    D_800BF918[object].position[0] = 0;
    D_800BF918[object].position[1] = 0;
    D_800BF918[object].position[2] = 0;
    D_800BF918[object].property12 = 0;
}
