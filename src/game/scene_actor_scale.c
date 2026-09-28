#include "../../include/object.h"
#include "../../include/text.h"

typedef struct SceneScaleActor {
    void (*callback00)(void);
    unsigned char unknown04[8];
    short objectIndex0C;
    unsigned char unknown0E[0xA];
    int frame18;
    unsigned char unknown1C[5];
    unsigned char state21;
    unsigned char unknown22[2];
    TextGlyphResource *resource24;
    unsigned char unknown28[0x20];
    int field48;
    int field4C;
} SceneScaleActor;

extern int D_8009EFA0;
extern void func_80005560(void);

void func_800369C8(SceneScaleActor *actor, int initialize)
{
    unsigned int elapsed;

    if (initialize != 0) {
        actor->callback00 = func_80005560;
        return;
    }

    elapsed = D_8009EFA0 - actor->field48;
    if (elapsed >= 750U) {
        actor->state21 = 2;
        return;
    }

    func_800399E4(
        actor->objectIndex0C,
        (float)(((elapsed * 20000U) / 750U) * actor->resource24->scale) / 40960.0f);

    actor->frame18 =
        ((unsigned int)(D_8009EFA0 - actor->field48) << 8) / 750U;
    actor->field4C =
        ((unsigned int)(D_8009EFA0 - actor->field48) << 8) / 750U;
}
