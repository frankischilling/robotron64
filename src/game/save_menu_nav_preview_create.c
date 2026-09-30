#include "../../include/save_menu_nav_internal.h"

void func_80025EF0(int x, int y, int z)
{
    int position[3];
    int flags;
    SaveMenuActorInternal *actor;

    if (D_800AEE98.previewActor1C == 0) {
        position[0] = x;
        position[1] = y - 40000;
        position[2] = z;
        func_8001CF68(&D_800B2218, 1);
        D_800AEE98.previewActor1C =
            (SaveMenuActorInternal *)func_800283D4(9, &D_800B2218, position);
        if (D_800AEE98.previewActor1C != 0) {
            actor = D_800AEE98.previewActor1C;
            func_800399E4(actor->objectIndex,
                          (float)(actor->resource24->scale * 0x12C) / 40960.0f);
            func_80027AB8((GameActor *)D_800AEE98.previewActor1C, 6, 1);
            flags = D_800AEE98.previewActor1C->flags14;
            if (flags & 0x40) {
                D_800AEE98.previewActor1C->flags14 = flags & ~0x40;
                D_800AEE98.previewActor1C->callback44(D_800AEE98.previewActor1C);
                flags = D_800AEE98.previewActor1C->flags14;
            }
            D_800AEE98.previewActor1C->flags14 = flags | 0x40;
            D_800AEE98.previewActor1C->callback44 = func_80025E68;
            D_800AEE98.previewActor1C->value0E = 0x3E7;
            D_800AEE98.value10 = 0;
            D_800AEE98.previewActor1C->flags14 &= ~0x20;
        }
    }
}
