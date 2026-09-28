#include "../../include/session_menu_internal.h"

void func_8002F4EC(void)
{
    SessionMenuPreview *preview;
    int frame;
    int index;

    frame = (D_80077B18 & 1) * 0x700;
    for (index = 0; index < 2; index++) {
        preview = &D_80077AE0[index];
        if (preview->firstActor != 0 &&
            func_80039E3C(preview->firstActor->objectIndex) != 0) {
            preview->firstActor->resource->animation.tracks[
                preview->firstActor->animationIndex]->frameDuration = 0;
            if (preview->firstActor->frame > frame) {
                preview->firstActor->frame -= D_8009EF94 * 4;
                if (preview->firstActor->frame < frame) {
                    preview->firstActor->frame = frame;
                }
            } else if (preview->firstActor->frame < frame) {
                preview->firstActor->frame += D_8009EF94 * 4;
                if (preview->firstActor->frame > frame) {
                    preview->firstActor->frame = frame;
                }
            }
        }
    }
}
