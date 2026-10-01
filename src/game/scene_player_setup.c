#include "../../include/scene_player_runtime_internal.h"
#include "../../include/scene_definition.h"

extern ScenePlayerRuntime D_8009B190[2];
extern TextGlyphResource D_8009B138;
extern int D_8009CCF8[];
extern int D_8009CD04;
extern int D_8009CD08;
extern int D_8009EFA0;
extern int D_800AD30C;
extern char D_80094200[];

extern void func_8001BF48(void *state);
extern void func_800290B0(int object, int *position);

void func_80032D28(int playerIndex, int initializeOnly, int xOffset)
{
    ScenePlayerRuntime *player;
    ActorBehaviorActorInternal *actor;
    int positionIndex;
    int count;

    player = &D_8009B190[playerIndex];
    player->field74 = 0;
    player->field70 = 0;
    player->field6C = -1;

    if (initializeOnly != 0) {
        player->field1C = D_800AD30C;
        player->field18 = 0;
        player->field00 = 0;
        player->field05 = 10;
        player->field01 = 0;
        count = 5;
    } else {
        positionIndex = player->field03 + playerIndex;
        if (D_800B9A78.positionEnabled[positionIndex] == 0) {
            do {
                positionIndex++;
                positionIndex %= 5;
            } while (D_800B9A78.positionEnabled[positionIndex] == 0);
        }

        count = 5;
        actor = (ActorBehaviorActorInternal *)func_800283D4(
            2, &D_8009B138, D_800B9A78.positions[positionIndex]);
        player->actor08 = actor;
        if (actor == 0) {
            func_8001C0D0(D_80094200);
        }

        func_80039BFC(player->actor08->objectIndex, 1);
        player->actor08->position[0] += xOffset;
        player->actor08->position[2] = 500;
        player->actor08->unknown10[0] = 0xFF;
        player->field0C = 0;
        D_8009CD04 = player->actor08->resource24->kind;
        D_8009CCF8[playerIndex] = player->actor08->objectIndex;
        player->actor08->angle08 = 0;
        func_80039514(player->actor08->objectIndex, player->actor08->angle08);
        player->actor08->field3C = (int)player;
        func_800290B0(player->actor08->objectIndex, player->actor08->position);
    }

    func_8001BF48(player->field34);
    player->field84 = count;
    player->field88 = count;
    player->field7C = 0;
    player->field04 = 0;
    player->field8C = D_8009EFA0;
    player->field14 = D_8009EFA0;
    player->field94 = D_8009EFA0;
    player->field98 = D_8009EFA0;
    player->field90 = D_8009EFA0;
    player->field80 = 0x100;
    D_8009CD08 = 0;
}
