#include "../../include/actor_motion_internal.h"
#include "../../include/save_game.h"
#include "../../include/palette_effects.h"

extern int D_800AD168;
extern int D_800AD288;
extern int D_800AD19C;
extern int D_8009EFA0;

int func_8003614C(int sound, int value, int enabled, int extra);
int func_80039EA0(int first, int second);
void func_80039F04(int enabled);

void func_80032F70(void)
{
    GameActor *actor;

    D_800AD288 = 4;
    if (!(D_8009B190[D_800AD168].saved.active +
          (D_8009B190[D_800AD168].saved.unknown06[0] < 0 ?
               0 : D_8009B190[D_800AD168].saved.unknown06[0]) - 1)) {
        func_8003614C(35, 0, 1, 0);
    }
    actor = D_800AA708;
    while (actor != 0) {
        if (actor->resource->unk00 == 0 && actor->animationIndex != 1 &&
            actor->animationIndex != 4) {
            if (actor->resource->actorKind < 5 || actor->resource->actorKind >= 9 ||
                actor->animationIndex != 3) {
                func_80027AB8(actor, 9, 1);
                actor->field48 = D_8009EFA0;
                actor->flags |= 0x8000;
            }
        }
        actor = actor->next;
    }
    func_800315E4(6);
    func_80039EA0(4, 1);
    func_80039F04(0);
    D_800AD19C = D_8009EFA0;
}
