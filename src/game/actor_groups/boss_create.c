#include "../../../include/early_session_state.h"
#include "../../../include/object.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/actor_animation_state.h"

typedef struct EarlyBossResourceSet {
    EarlySceneResourceRecord resources[5];
    unsigned char unknown1E0[0x20C];
} EarlyBossResourceSet;

/* The selector multiplies its index by 0x3EC; only the first five resources
 * are interpreted by this routine. */
typedef char EarlyBossResourceSetMustBe1004Bytes[
    sizeof(EarlyBossResourceSet) == 0x3EC ? 1 : -1];

extern int D_8009EFA0;
extern int D_80097354;
extern int D_80097358;
extern EarlyAnimationRecord *D_8007356C[];
static const unsigned char D_8008FB8C[] = "Can't create Boss part\n";
void func_8000F7D8(void);
void func_8000EE48(EarlyGameActor *actor);
void func_8001C0D0(unsigned char *format, ...);

EarlyGameActor *func_8001049C(int index, int *position, int phase)
{
    D_80097354 = D_8009EFA0;
    D_80097358 = D_8009EFA0;
    D_800AD138.animationResources84 = (EarlySceneResourceRecord *)
        ((EarlyBossResourceSet *)D_8009EA18 + index);
    D_800AD138.animationRecordsB4 = D_8007356C[index];
    if (phase < 0) {
        return 0;
    }
    if (phase == 0) {
        func_8000F7D8();
        D_800AD138.animationLimitA0 = 5;
        D_800AD138.animationIndex9C = 4;
        D_8009B190[D_800AD138.saved.currentPlayer].saved.value24 = 25600;
    }
    position[0] = 0;
    position[1] = -20000;
    position[2] = 0;
    D_800AD138.animationActor80 = (EarlyGameActor *)func_800283D4(8,
        (TextGlyphResource *)D_800AD138.animationResources84[
            D_800AD138.animationIndex9C > 4 ? 4 : D_800AD138.animationIndex9C].resource04,
        position);
    if (D_800AD138.animationActor80 != 0) {
        D_800AD138.animationActor80->angle08 = 1024;
        /* Retail retains this read and write. */
        D_800AD138.animationActor80->field2C = D_800AD138.animationActor80->field2C;
        D_800AD138.animationActor80->field6C =
            func_8003CC88(D_800AD138.animationActor80->angle08) *
            D_800AD138.animationActor80->field2C / 4096;
        D_800AD138.animationActor80->field70 =
            func_8003CC58(D_800AD138.animationActor80->angle08) *
            D_800AD138.animationActor80->field2C / 4096;
        func_80039514(D_800AD138.animationActor80->objectIndex0C,
            D_800AD138.animationActor80->angle08);
        func_800399E4(D_800AD138.animationActor80->objectIndex0C,
            (float)(D_800AD138.animationActor80->resource24->scale0C * 2028) / 40960.0f);
        D_800AD138.animationActor80->position.value[2] = 0;
    } else {
        func_8001C0D0((unsigned char *)D_8008FB8C);
    }
    if (phase != 0) {
        func_80027AB8((GameActor *)D_800AD138.animationActor80, 0, 1);
    } else {
        func_80027AB8((GameActor *)D_800AD138.animationActor80, 8, 1);
    }
    D_800AD138.animationActor80->value10[0] =
        D_8009B190[D_800AD138.saved.currentPlayer].saved.value24;
    D_800AD138.animationReady90 = 1;
    if (D_800AD138.animationIndex9C == D_800AD138.animationLimitA0) {
        func_8000EE48(D_800AD138.animationActor80);
    } else {
        func_8000EDE0(D_800AD138.animationActor80);
    }
    return D_800AD138.animationActor80;
}
