#include "../../../include/early_bonus_internal.h"
#include "../../../include/early_game_more.h"
#include "../../../include/graphics_state_internal.h"
#include "../../../include/actor_resource_internal.h"

extern int D_800736A8;
extern int D_800BA748;
extern int D_80097354;
extern int D_80073588;

typedef struct BossRetainedInitializerWords {
    int words[3];
} BossRetainedInitializerWords;

typedef struct BossRetainedInitializerBytes {
    unsigned char bytes[4];
} BossRetainedInitializerBytes;

typedef char BossRetainedInitializerWordsMustBe12Bytes[
    sizeof(BossRetainedInitializerWords) == 12 ? 1 : -1];
typedef char BossRetainedInitializerBytesMustBe4Bytes[
    sizeof(BossRetainedInitializerBytes) == 4 ? 1 : -1];

/* Retail copies these initializers to locals that it never reads again.
 * Their original declarations and intended uses remain unknown. */
static BossRetainedInitializerWords D_800736B8 = {{20000, 20000, 0}};
static BossRetainedInitializerBytes D_800736C4 = {{0, 255, 0, 0}};
static BossRetainedInitializerBytes D_800736C8 = {{255, 0, 0, 0}};
static BossRetainedInitializerBytes D_800736CC = {{0, 0, 255, 0}};

void func_800107A0(void)
{
    /* Measured unused stack storage; the original local type is unknown. */
    unsigned char unknownStackStorage[8];
    BossRetainedInitializerWords retainedWords = D_800736B8;
    BossRetainedInitializerBytes retainedC4 = D_800736C4;
    BossRetainedInitializerBytes retainedC8 = D_800736C8;
    BossRetainedInitializerBytes retainedCC = D_800736CC;
    int index;

    if (D_800BA748 == 200) {
        func_80046EA8(186, 0, 0, 200);
    } else {
        func_80046EA8(186, 250, 235, 35);
    }
    if (D_800AD138.animationReady90 != 0 &&
        D_800AD138.animationActor80 != 0 &&
        D_800AD138.animationActor80->state21 == 0) {
        if (D_800AD138.animationActor80->animation1F == 5 &&
            D_800AD138.animationIndex9C == 2) {
            ((ActorResource58Internal *)D_800AD138.animationActor80->resource24)->playbackSpeed =
                D_800736A8 * 3;
        } else {
            ((ActorResource58Internal *)D_800AD138.animationActor80->resource24)->playbackSpeed =
                D_800736A8;
        }
        if (D_800AD138.value8C == 0 &&
            (unsigned int)(D_8009EFA0 - D_80097354) > 100) {
            D_80097354 = D_8009EFA0;
            func_80009F90(D_800AD138.animationActor80, 0);
        }
        func_8000F814(D_800AD138.animationActor80);
        if (D_8009734C != 0) {
            if ((unsigned int)(D_8009EFA0 - D_80097344) > 700) {
                D_80097344 = D_8009EFA0;
                for (index = 0; index != 10; index++) {
                    func_8000F030((ActorBehaviorActorInternal *)D_800AD138.animationActor80,
                        index, 4);
                }
                D_8009734C--;
            }
        } else if (D_80097348 != 0 &&
            (unsigned int)(D_8009EFA0 - D_80097340) > 100) {
            D_80097340 = D_8009EFA0;
            func_8000F030((ActorBehaviorActorInternal *)D_800AD138.animationActor80, 5, 9);
            D_80097348--;
        }
        D_8009B190[D_800AD138.saved.currentPlayer].saved.value24 =
            D_800AD138.animationActor80->value10[0];
        if (D_800AD138.animationActor80->value10[0] <= 0 && D_80073588 <= 0) {
            D_800AD138.animationReady90 = 0;
        }
    }
}
