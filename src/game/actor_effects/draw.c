#include "../../../include/effect_draw_config_internal.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/renderer_draw_state_internal.h"
#include "../../../include/renderer_geometry_internal.h"
#include "../../../include/renderer_texture_index.h"

void func_8004ABBC(int value);
void func_8004A6B4(unsigned char *address);
void func_8004A938(unsigned char *address);

int func_80005560(EarlyGameActor *actor)
{
    int index;
    int selected = 0;
    int frame;
    int position[3];
    unsigned char *bitmap;
    FixedMatrix matrix;
    ObjectRecord *record;
    EffectDrawConfig *config;
    int scale;

    /* An unknown resource uses the first configuration. */
    for (index = 0; index < 31; index++) {
        if (actor->resource24 == D_80072C00[index].resource) {
            selected = index;
            break;
        }
    }
    config = &D_80072C00[selected];
    frame = config->frameDelta * actor->field4C / 256 + config->frame;
    func_8004729C(15);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xBA000C02, 0x2000);
    FRAME_COMMAND(0xBA001001, 0);
    FRAME_COMMAND(0xBA001301, 0x80000);
    func_80049AD8(config->palette);

    record = &D_800BF918[actor->objectIndex0C];
    /* Camera-relative coordinates are halved with arithmetic shifts. */
    position[0] = (record->position[0] - D_800C8BD8.position[0]) >> 1;
    position[1] = (config->height * 12 + record->position[1] -
                   D_800C8BD8.position[1]) >> 1;
    position[2] = (record->position[2] - D_800C8BD8.position[2]) >> 1;
    func_8004D4B4(((RendererDrawState *)&record->draw38)->projectedPosition,
                  &D_800CD250, position);
    func_8004ABBC(config->flagDelta * actor->field4C / 256 + config->flag);
    scale = (config->scaleDelta * actor->field4C / 256 + config->scale) >> 4;
    record->scale[0] = scale;
    record->scale[1] = scale;
    record->scale[2] = scale;
    bitmap = D_8007BAC4[((ActorResource58Internal *)actor->resource24)->
                       bitmapHandle24].data + frame * 1024;
    if (config->billboard == 0) {
        func_8004DB34(&matrix);
        func_80047A08((RendererDrawState *)&record->draw38, &matrix);
        func_8004A6B4(bitmap);
    } else {
        func_80047A08((RendererDrawState *)&record->draw38, &D_800CD250);
        func_8004A938(bitmap);
    }
    return 0;
}
