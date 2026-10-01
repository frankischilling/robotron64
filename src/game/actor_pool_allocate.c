#include "../../include/actor_resource_internal.h"
#include "../../include/game_memory.h"

extern int D_800A4620;
extern GameActor *D_800AA708;
extern int D_800ACD90[11];
extern int D_8009EFA0;
extern unsigned char *D_800759EC[];

GameActor D_800A4628[200];

static const unsigned char D_8009390C[] = "Cannot create object, no slots available\n";
static const unsigned char D_80093938[] = "Loading a %s during game\n";
static const unsigned char D_80093954[] = "idx %d\n";
static const unsigned char D_8009395C[] = "idx %d\n";
static const unsigned char D_80093964[] = "idx %d\n";
extern void func_8001C2C4(unsigned char *format, ...);
extern void func_800290B0(int object, int *position);

GameActor *func_800283D4(int kind, TextGlyphResource *resource, int *position)
{
    GameActor *scan;
    int object;
    GameActor *actor;
    int index;

    if (D_800A4620 == 200) {
        func_8001C2C4((unsigned char *)D_8009390C);
        return 0;
    }
    if (!resource->flags06.bits.loaded) {
        func_8001C2C4((unsigned char *)D_80093938, D_800759EC[kind]);
        switch (kind) {
        case 0:
            func_8001C2C4((unsigned char *)D_80093954,
                ((unsigned char *)D_800AF1F0 - (unsigned char *)resource) / 104);
            break;
        case 9:
            func_8001C2C4((unsigned char *)D_8009395C,
                ((unsigned char *)D_800B1BE8 - (unsigned char *)resource) / 88);
            break;
        case 4:
        case 5:
            func_8001C2C4((unsigned char *)D_80093964,
                ((unsigned char *)D_800AC998 - (unsigned char *)resource) / 92);
            break;
        }
        func_8001CF68(resource, 1);
    }
    for (index = 0; index < 200; index++) {
        scan = &D_800A4628[index];
        if (scan->kind == 11) {
            actor = scan;
            break;
        }
    }
    object = func_8003921C(resource->kind, resource->field12,
                            (ObjectDrawResource *)actor,
                            (ObjectModel *)resource);
    if (object == -1) {
        return 0;
    }
    func_8003B694(actor, 0, sizeof(GameActor));
    if (D_800AA708 != 0) {
        actor->next = D_800AA708;
    } else {
        actor->next = 0;
    }
    D_800AA708 = actor;
    D_800A4620++;
    actor->objectIndex = object;
    actor->resource = resource;
    actor->kind = kind;
    if (kind == 5) {
        D_800ACD90[resource->actorKind]++;
    }
    actor->unknown00[2] = actor->resource->field12;
    actor->position[0] = position[0];
    actor->position[1] = position[1];
    actor->position[2] = position[2];
    actor->field74 = 0;
    actor->unknown0E[1] = actor->resource->field14;
    actor->unknown00[3] = (resource->playbackSpeed * 3000) / 96;
    actor->state = 0;
    actor->field34 = -1;
    func_800399E4(actor->objectIndex, (actor->resource->scale << 12) / 40960.0f);
    func_800290B0(actor->objectIndex, actor->position);
    func_80027AB8(actor, 0, 1);
    actor->field48 = D_8009EFA0;
    actor->field5C = actor->resource->field54;
    return actor;
}
