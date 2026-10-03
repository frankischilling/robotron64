#include "../../include/early_session_state.h"
#include "../../include/object.h"

extern EarlyAnimationRecord D_80073164[];
extern unsigned char D_8008FB70[];
void func_80039EB8(int value, unsigned char flags);
void func_8001C0D0(unsigned char *format, ...);

void func_8000EE48(EarlyGameActor *child)
{
    EarlyAnimationSlot *slot;
    int index;

    {
        EarlyGameActor *parent;
        int resourceIndex;

        D_800AD138.animationIndex9C--;
        parent = child;
        child->state21 = 2;
        resourceIndex = D_800AD138.animationIndex9C > 4 ? 4 : D_800AD138.animationIndex9C;
        child = D_800AD138.animationActor80 = (EarlyGameActor *)func_800283D4(8,
            (TextGlyphResource *)D_800AD138.animationResources84[resourceIndex].resource04,
            child->position.value);
        if (child != 0) {
            func_800399E4(child->objectIndex0C,
                (float)(child->resource24->scale0C * 2028) / 40960.0f);
            child->angle08 = parent->angle08;
            func_80039514(child->objectIndex0C, child->angle08);
            child->value10[0] = parent->value10[0];
        } else {
            func_8001C0D0(D_8008FB70);
        }
    }
    if (D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].sceneAnimation00 != -1) {
        func_8000ECE4(child,
            D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].sceneAnimation00,
            0, 0, D_80073164[D_800AD138.animationIndex9C].value15);
        func_80039EB8(10, 5);
        D_800AD138.animationStateA8 = 0;
    } else {
        func_8000EDE0(child);
    }
    slot = D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].resetA8;
    for (index = 0; index < 3 && slot->reset.value00 != -1; index++, slot++) {
        slot->reset.enabled08 = 0;
    }
}
