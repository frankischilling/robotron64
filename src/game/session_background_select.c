#include "../../include/graphics_state_internal.h"
#include "../../include/renderer_texture_cache.h"

#include "../../include/scene_background_internal.h"

void func_800465B0(int red, int green, int blue);

void func_80022BFC(void)
{
    SceneBackgroundRecord *record;
    BackgroundColorRecord *colors;

    D_8007BB18 = D_80074C08[D_800AD160].kind & 0x7F;
    switch (D_8007BB18) {
        case 1:
        case 2:
        case 3:
        case 6:
        case 7:
        case 8:
            D_8007BB18 = 0;
            break;
        case 0:
        case 4:
        case 5:
        case 9:
        case 10:
            break;
    }
    func_800465B0(70, 50, -70);
    record = &D_80074C08[D_800AD160];
    D_800CDBC0 = record->texture;
    colors = &D_80074BC4[record->colors];
    D_800ACE18 = colors->first[0];
    D_800ACE24 = colors->first[1];
    D_800ACE34 = colors->first[2];
    D_800ACE1C = colors->second[0];
    D_800ACE2C = colors->second[1];
    D_800ACE40 = colors->second[2];
}
