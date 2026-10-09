#include "../../include/object_runtime.h"
#include "../../include/renderer_resource_storage.h"
#include "../../include/renderer_geometry_internal.h"

typedef struct ObjectProjectionResourceArena {
    unsigned char unknown00[16];
    RendererModelCacheRecord models[400];
    RendererAnimationCacheRecord animations[400];
} ObjectProjectionResourceArena;
typedef struct ObjectProjectionContext {
    unsigned char unknown00[10];
    short index0A;
} ObjectProjectionContext;

extern ObjectProjectionContext *D_8009B168;
extern int D_800BEF64;
extern int D_800BEF6C;
extern ObjectRecoveryDatPoint D_800C8C10[];
void func_8003F818(int count, RendererNormal *output,
                  RendererNormal *first, RendererNormal *second);
extern void func_8004BD00(int model, int animation, int bitmap);

#define ANIMATION_CACHE (((ObjectProjectionResourceArena *)D_80078274)->animations)

/* Excluded candidate; complete retail range still differs. */
void func_8003B2B0(int index, int frame)
{
    int referenceIndex;
    int count;
    int phase;
    int i;
    ObjectRecoveryDatPoint *source;
    ObjectRecoveryDatPoint *output;

    referenceIndex = D_8009B168->index0A;
    func_8004BD00(-1, referenceIndex, -1);
    count = ANIMATION_CACHE[index].pointCount;
    phase = ((D_800BEF6C - D_800BEF64) & 0xFFF) / 512 * 10;
    func_8003F818(count, (RendererNormal *)D_800C8C10,
        (RendererNormal *)(ANIMATION_CACHE[index].data + count * frame),
        (RendererNormal *)(ANIMATION_CACHE[referenceIndex].data +
            ANIMATION_CACHE[referenceIndex].pointCount * phase));
    count = ANIMATION_CACHE[index].pointCount;
    source = ANIMATION_CACHE[index].data + count * ANIMATION_CACHE[index].frameCount;
    output = D_800C8C10 + count;
    i = 0;
    if (count > 0) {
        do {
            *output++ = *source++;
            i++;
        } while (i < ANIMATION_CACHE[index].pointCount);
    }
    ANIMATION_CACHE[254].data = D_800C8C10;
    ANIMATION_CACHE[254].loaded = 1;
    ANIMATION_CACHE[254].unknown0D = 1;
    ANIMATION_CACHE[254].frameCount = 1;
    ANIMATION_CACHE[254].pointCount = ANIMATION_CACHE[index].pointCount;
}
