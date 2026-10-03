#include "../../../include/actor_setup_internal.h"
#include "../../../include/early_session_state.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/object.h"
#include "../../../include/scene_commands_internal.h"

extern int D_8007358C;
extern int D_800739CC;
extern int D_8009EFA0;

void func_8000F814(EarlyGameActor *actor)
{
    int index;
    int position[3];
    EarlyGameActor *created;
    unsigned int color;
    int duration = 500;

    if (D_800739CC != 0 &&
        (unsigned int)(D_8009EFA0 - D_800739CC) < 500) {
        color = (unsigned int)((duration - D_8009EFA0 + D_800739CC) * 200) / duration;
        func_80039C1C(actor->objectIndex0C, color, color, 0);
    }
    for (index = 0; D_80073590[index].value00 != -1; index++) {
        if (D_80073590[index].value00 == 0 &&
            (unsigned int)(D_8009EFA0 - D_8007358C) > 1000 &&
            (D_800AD138.animationIndex9C < D_80073590[index].animationIndex04 ||
             (D_800AD138.animationIndex9C == D_80073590[index].animationIndex04 &&
              actor->animation1F == D_80073590[index].animation0C &&
              (D_80073590[index].frame10 << 8) < actor->frame18))) {
            if (D_80073590[index].actorResourceIndex != -1) {
                position[0] = D_800AD138.animationActor80->position.value[0] +
                    func_8003CC88(actor->angle08) * 8000 / 4096;
                position[1] = D_800AD138.animationActor80->position.value[1] +
                    func_8003CC58(actor->angle08) * 8000 / 4096;
                /* Retail leaves position[2] uninitialized. */
                created = (EarlyGameActor *)func_800283D4(9,
                    &D_800B1BE8[D_80073590[index].actorResourceIndex], position);
                if (created != 0) {
                    D_8007358C = D_8009EFA0;
                    func_800399E4(created->objectIndex0C,
                        (float)(created->resource24->scale0C * 20280) / 40960.0f);
                    func_80039C1C(created->objectIndex0C, 255, 255, 0);
                    D_80073590[index].value00 = 1;
                    created->angle08 = func_8003CD4C(
                        ((EarlyGameActor *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position.value[1] - actor->position.value[1],
                        ((EarlyGameActor *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position.value[0] - actor->position.value[0]);
                    created->field2C = 50;
                    created->field6C = func_8003CC88(created->angle08) * 50 / 4096;
                    created->field70 = func_8003CC58(created->angle08) * 50 / 4096;
                    func_80039514(created->objectIndex0C, created->angle08);
                }
            }
            if (D_80073590[index].extraResourceIndex != -1) {
                func_8001FCE4(1, 0, D_80073590[index].extraResourceIndex, 1, 1,
                    D_80073590[index].extraCount18, -1, -1);
            }
        }
    }
}
