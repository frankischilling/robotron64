#include "../../../include/actor_damage_internal.h"
#include "../../../include/early_game_state.h"
#include "../../../include/scene_counter_internal.h"
#include "../../../include/save_game.h"

extern int D_8009CD08;
extern int D_800739BC[3];
extern int D_800AE560;
extern int D_800B6FD4;
void func_8003BF9C();
int func_8003614C(int sound, int unused, int enabled, int fourth);

int func_80015F00(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second,
                  int *firstPosition, int *secondPosition)
{
    EarlyGameActor *extra;
    int position[3];
    int sound;
    int red;
    int green;
    int blue;
    EarlyGameActor *created;

    if (second->resource24->actorKind < 4) {
        if (D_800B8F78.value04 == 0) D_800B8F78.value04 = -1;
        if (D_8009CD08 < 3 && second->resource24->actorKind == D_800739BC[D_8009CD08]) D_8009CD08++;
        switch (second->resource24->actorKind) {
        case 1:
            sound = 64;
            red = 240;
            green = 0;
            blue = 240;
            break;
        case 2:
            sound = 66;
            red = 240;
            green = 0;
            blue = 0;
            break;
        case 0:
            sound = 65;
            red = 0;
            green = 0;
            blue = 240;
            break;
        case 3:
            sound = 67;
            red = 240;
            green = 240;
            blue = 128;
            break;
        }
        func_80039C1C(first->objectIndex, red, green, blue);
        func_8003BF9C(8);
        func_8003614C(8, 0, 1, 0);
        func_8003614C(sound, 0, 1, 0);
        if (D_800AD138.value4C < 5000) D_800AD138.value4C += 1000;
        func_80037144(D_800AD138.value4C, (SceneBucketCounter *)first->field3C);
        position[0] = (secondPosition[0] + firstPosition[0]) / 2;
        position[1] = (secondPosition[1] + firstPosition[1]) / 2;
        position[2] = 0;
        if (D_800AE560 != 3) {
            created = (EarlyGameActor *)func_800283D4(9, &D_800B1BE8[D_800AD138.value4C / 1000 + 9], position);
            if (created != 0) created->resource24->callback54(created, 1);
        }
        if (D_8009CD08 == 3) {
            func_80037144(D_800AD138.value4C, (SceneBucketCounter *)first->field3C);
            if (D_800AE560 != 3) {
                extra = (EarlyGameActor *)func_800283D4(9, &D_800B1BE8[D_800AD138.value4C / 1000 + 9], position);
                if (extra != 0) {
                    extra->resource24->callback54(extra, 1);
                    extra->field48 -= D_800B6FD4 / 3;
                }
            }
        }
        D_800AD138.activeSceneActors[second->resource24->actorKind]--;
        return 32;
    } else if (first->animation1F != 1) {
        func_80035244(first, second);
    }
    return 0;
}
