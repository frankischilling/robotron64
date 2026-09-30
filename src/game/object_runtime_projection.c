#include "../../include/object_runtime.h"

typedef struct ObjectRuntimeRecord8 {
    unsigned char bytes[8];
} ObjectRuntimeRecord8;

typedef struct ObjectRuntimeSlotView {
    unsigned char unknown0000[0x1F50];
    ObjectRuntimeRecord8 *records;
    int count;
    int frame;
    int unused0C;
} ObjectRuntimeSlotView;

typedef struct ObjectRuntimeArena {
    unsigned char unknown0000[0x2F30];
    ObjectRuntimeRecord8 *output;
    int outputCount;
    int outputActive;
    unsigned char outputReady;
    unsigned char outputDirty;
} ObjectRuntimeArena;

typedef struct ObjectRuntimeContext {
    unsigned char unknown00[0x0A];
    short index0A;
} ObjectRuntimeContext;

extern ObjectRuntimeContext *D_8009B168;
extern int D_800BEF64;
extern int D_800BEF6C;
extern ObjectRuntimeRecord8 D_800C8C10[];

extern void func_8003F818(int count, ObjectRuntimeRecord8 *output,
                         ObjectRuntimeRecord8 *source,
                         ObjectRuntimeRecord8 *reference);
extern void func_8004BD00(int first, int second, int third);

void func_8003B2B0(int index, int frame)
{
    ObjectRuntimeSlotView *slot;
    ObjectRuntimeSlotView *referenceSlot;
    ObjectRuntimeRecord8 *output;
    ObjectRuntimeRecord8 *source;
    int referenceIndex;
    int preCount;
    int postCount;
    int i;

    referenceIndex = D_8009B168->index0A;
    func_8004BD00(-1, referenceIndex, -1);

    slot = (ObjectRuntimeSlotView *)(D_80078274 + index * 0x10);
    preCount = slot->count;
    referenceSlot = (ObjectRuntimeSlotView *)(D_80078274 +
                                               referenceIndex * 0x10);
    func_8003F818(preCount, D_800C8C10,
                  slot->records + preCount * frame,
                  referenceSlot->records + referenceSlot->count *
                      ((((D_800BEF6C - D_800BEF64) & 0xFFF) / 512) * 10));

    postCount = slot->count;
    output = D_800C8C10 + postCount;
    source = slot->records + postCount * slot->frame;
    i = 0;
    if (postCount > 0) {
        do {
            *output++ = *source++;
            i++;
        } while (i < slot->count);
    }

    ((ObjectRuntimeArena *)D_80078274)->output = D_800C8C10;
    ((ObjectRuntimeArena *)D_80078274)->outputReady = 1;
    ((ObjectRuntimeArena *)D_80078274)->outputDirty = 1;
    ((ObjectRuntimeArena *)D_80078274)->outputActive = 1;
    ((ObjectRuntimeArena *)D_80078274)->outputCount = slot->count;
}
